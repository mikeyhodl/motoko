{
  description = "The Motoko compiler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    flake-utils.url = "github:numtide/flake-utils";

    nix-update-flake.url = "github:Mic92/nix-update";
    nix-update-flake.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    esm = {
      url = "https://registry.npmjs.org/esm/-/esm-3.2.25.tgz";
      flake = false;
    };
    viper-server = {
      url = "https://github.com/viperproject/viperserver/releases/download/v.22.11-release/viperserver.jar";
      flake = false;
    };

    candid-src = {
      url = "github:dfinity/candid";
      flake = false;
    };
    ic-src = {
      url = "github:dfinity/ic";
      flake = false;
    };
    ic-wasm-src = {
      url = "github:dfinity/ic-wasm";
      flake = false;
    };
    libtommath-src = {
      url = "github:libtom/libtommath/v1.2.0";
      flake = false;
    };
    motoko-base-src = {
      url = "github:dfinity/motoko-base/next-moc";
      flake = false;
    };
    motoko-matchers-src = {
      url = "github:kritzcreek/motoko-matchers";
      flake = false;
    };
    ocaml-vlq-src = {
      url = "github:flowtype/ocaml-vlq";
      flake = false;
    };
    wasm-spec-src = {
      url = "github:WebAssembly/spec/opam-1.1.1";
      flake = false;
    };
    ocaml-recovery-parser-src = {
      url = "github:serokell/ocaml-recovery-parser";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , nix-update-flake
    , rust-overlay
    , esm
    , viper-server
    , candid-src
    , ic-src
    , ic-wasm-src
    , libtommath-src
    , motoko-base-src
    , motoko-matchers-src
    , ocaml-vlq-src
    , wasm-spec-src
    , ocaml-recovery-parser-src
    }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import ./nix/pkgs.nix {
        inherit nixpkgs system rust-overlay;
        sources = {
          inherit
            candid-src
            ic-src
            ic-wasm-src
            libtommath-src
            motoko-base-src
            motoko-matchers-src
            ocaml-vlq-src
            wasm-spec-src
            ocaml-recovery-parser-src;
        };
      };

      llvmEnv = ''
        # When compiling to wasm, we want to have more control over the flags,
        # so we do not use the nix-provided wrapper in clang
        export WASM_CLANG="clang-18"
        export WASM_LD=wasm-ld
        # because we use the unwrapped clang, we have to pass in some flags/paths
        # that otherwise the wrapped clang would take care for us
        export WASM_CLANG_LIB="${pkgs.llvmPackages_18.clang-unwrapped.lib}"

        # When compiling natively, we want to use `clang` (which is a nixpkgs
        # provided wrapper that sets various include paths etc).
        # But for some reason it does not handle building for Wasm well, so
        # there we use plain clang-18. There is no stdlib there anyways.
        export CLANG="${pkgs.clang_18}/bin/clang"
      '';

      rts = import ./nix/rts.nix { inherit pkgs llvmEnv; };

      commonBuildInputs = pkgs: with pkgs; [ dune_3 obelisk perl removeReferencesTo ] ++ (with ocamlPackages; [
        ocaml
        checkseum
        findlib
        menhir
        menhirLib
        menhirSdk
        ocaml-recovery-parser
        cow
        num
        stdint
        wasm_1
        vlq
        zarith
        yojson
        ppxlib
        ppx_blob
        ppx_inline_test
        ppx_expect
        bisect_ppx
        uucp
      ]);

      moPackages = officialRelease: import ./nix/mo-packages.nix { inherit pkgs commonBuildInputs rts officialRelease; };
      releaseMoPackages = moPackages true;
      debugMoPackages = moPackages false;
      buildableMoPackages = moPackages: { inherit (moPackages) moc mo-ld mo-doc didc deser; };
      buildableReleaseMoPackages = buildableMoPackages releaseMoPackages;
      buildableDebugMoPackages = buildableMoPackages debugMoPackages;

      tests = import ./nix/tests.nix { inherit pkgs llvmEnv esm viper-server commonBuildInputs debugMoPackages; };

      filterTests = type:
        pkgs.lib.mapAttrsToList (_name: drv: drv) (pkgs.lib.filterAttrs
          (name: _drv:
            let
              matchDebug = builtins.match ".*-debug$" name;
              matchRelease = builtins.match ".*-release$" name;
              matchGC = builtins.match ".*-gc$" name;
              # Common tests are those that do not match -debug, -release, or -gc.
              matchCommon = matchDebug == null &&
                matchRelease == null &&
                matchGC == null;
            in {
              "debug" = matchDebug != null;
              "release" = matchRelease != null;
              "gc" = matchGC != null;
              "common" = matchCommon;
            }.${type})
          tests);

      base-src = pkgs.symlinkJoin {
        name = "base-src";
        paths = [ "${pkgs.sources.motoko-base-src}/src" ];
      };

      js = import ./nix/moc.js.nix { inherit pkgs commonBuildInputs rts; };

      docs = import ./nix/docs.nix { inherit pkgs js base-src; };

      checks = {
        check-formatting = import ./nix/check-formatting.nix { inherit pkgs; };
        check-rts-formatting = import ./nix/check-rts-formatting.nix { inherit pkgs; };
        check-grammar = import ./nix/check-grammar.nix { inherit pkgs; };
        check-error-codes = import ./nix/check-error-codes.nix { inherit pkgs; };
      };

      nix-update = nix-update-flake.packages.${system}.default;

      shell = import ./nix/shell.nix {
        inherit pkgs nix-update base-src llvmEnv esm viper-server commonBuildInputs rts js debugMoPackages docs;
        inherit (checks) check-rts-formatting;
      };

      common-constituents = rec {
        samples = import ./nix/samples.nix { inherit pkgs; inherit (debugMoPackages) moc; };
        base-tests = import ./nix/base-tests.nix { inherit pkgs; inherit (debugMoPackages) moc; };
        base-doc = import ./nix/base-doc.nix { inherit pkgs; inherit (debugMoPackages) mo-doc; };
        report-site = import ./nix/report-site.nix { inherit pkgs base-doc docs; inherit (tests) coverage; };

        inherit rts base-src docs shell;
      };
    in
    {
      packages = checks // common-constituents // rec {
        "release" = buildableReleaseMoPackages;
        "debug" = buildableDebugMoPackages;

        inherit nix-update tests js;

        inherit (pkgs) nix-build-uncached drun ic-wasm;

        release-files = import ./nix/release-files.nix { inherit self pkgs; };

        # Common tests version - includes non-GC, non-release/debug specific tests.
        common-tests = pkgs.releaseTools.aggregate {
          name = "common-tests";
          constituents = filterTests "common";  # Only include common tests.
        };

        # GC tests version - only includes GC tests.
        gc-tests = pkgs.releaseTools.aggregate {
          name = "gc-tests";
          constituents = filterTests "gc";  # Only include GC tests.
        };

        # Release version - excludes debug tests.
        release-systems-go = pkgs.releaseTools.aggregate {
          name = "release-systems-go";
          constituents =
            pkgs.lib.attrValues common-constituents ++
              pkgs.lib.attrValues checks ++
              pkgs.lib.attrValues buildableReleaseMoPackages ++
              filterTests "release" # Only include release tests.
              ++ builtins.attrValues js;
        };

        # Debug version - only includes debug tests.
        debug-systems-go = pkgs.releaseTools.aggregate {
          name = "debug-systems-go";
          constituents =
            pkgs.lib.attrValues common-constituents ++
              pkgs.lib.attrValues checks ++
              pkgs.lib.attrValues buildableDebugMoPackages ++
              filterTests "debug"  # Only include debug tests
              ++ builtins.attrValues js;
        };

        default = release-systems-go;
      };

      checks = checks // tests;

      devShells.default = shell;

      formatter = pkgs.writeShellScriptBin "formatter" ''
        if [[ $# = 0 ]]; then set -- .; fi
        exec "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt" "$@"
      '';
    });
}
