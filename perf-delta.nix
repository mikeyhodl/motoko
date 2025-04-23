# This nix derivation calculates a comparison between the performance numbers of two commits.
# This is used on CI (see CI.md).
#
# It runs the old and the new moc on all tests files. If the output is
# identical, it reports that no changes happened.
#
# Else it compares the performance statistics from the `tests.perf` derivation.

{ ref, from, to }:
let
  flake = builtins.getFlake (toString ./.);
  system = builtins.currentSystem;
  pkgs = import flake.inputs.nixpkgs { inherit system; };

  # Wrap in a derivation to fix path to perl in shebang
  diff-stats = pkgs.stdenvNoCC.mkDerivation {
    name = "diff-stats";
    src = ./test/diff-stats.pl;
    phases = [ "installPhase fixupPhase" ];
    buildInputs = [ pkgs.perl ];
    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/diff-stats
    '';
  };

  wasm-hash-for = moc:
    pkgs.stdenvNoCC.mkDerivation {
      name = "wasm-hash";
      src = ./test;
      buildInputs = [ moc ];
      buildPhase = ''
        moc --version
        for file in */*.mo
        do
          # ignore all errors
          echo -n $file
          if timeout 10s moc $file --omit-metadata motoko:compiler -no-check-ir -ref-system-api -o $file.wasm 2>/dev/null
          then echo " ok"
          else echo " failed (ignored)"
          fi
        done

        if ! test -n "$(find . -name \*.wasm -print -quit)"
        then
          echo "No wasm files generated. wasm-hash-for broken?"
          exit 1
        fi
      '';
      installPhase = ''
        sha256sum **/*.wasm > $out
      '';
    };

  checkout = rev: builtins.fetchGit { url = ./.; ref = ref; inherit rev; };

  baseCheckout = checkout from;

  isBaseFlake = builtins.hasAttr "flake.nix" (builtins.readDir baseCheckout);

  flakeOf = dir:
    let
      flakePath = builtins.unsafeDiscardStringContext "${dir}";
    in
    builtins.getFlake flakePath;

  # TODO: This if-then-else is only needed for the transition from default.nix to flake.nix.
  # After https://github.com/dfinity/motoko/pull/5067 is merged we can remove it and just use flakes.
  baseArgs =
    if isBaseFlake
    then
      let
        baseFlake = flakeOf baseCheckout;
      in
      {
        baseMoc = baseFlake.packages.${system}.debug.moc;
        basePerf = baseFlake.checks.${system}.perf;
      }
    else
      let
        baseJobs = import baseCheckout { };
      in
      {
        baseMoc = baseJobs.moc;
        basePerf = baseJobs.tests.perf;
      };
  inherit (baseArgs) baseMoc basePerf;

  prCheckout = checkout to;

  prFlake = flakeOf prCheckout;
  prMoc = prFlake.packages.${system}.debug.moc;

  baseWasm = wasm-hash-for baseMoc;
  prWasm = wasm-hash-for prMoc;

  prPerf = prFlake.checks.${system}.perf;
in
pkgs.runCommandNoCC "perf-delta"
{
  nativeBuildInputs = [ pkgs.coreutils diff-stats ];
} ''
  echo "Comparing from ${from} to ${to}:" > $out
  if cmp -s ${baseWasm} ${prWasm}
  then
    echo "The produced WebAssembly code seems to be completely unchanged." >> $out
  else
    diff-stats \
      ${basePerf}/stats.csv \
      ${prPerf}/stats.csv >> $out;
  fi
''
