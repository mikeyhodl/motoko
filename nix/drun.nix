pkgs: pkgs.rustPlatform-stable.buildRustPackage {
  pname = "drun";
  version = builtins.substring 0 7 pkgs.sources.ic-src.rev;

  src = pkgs.sources.ic-src;

  # update this after bumping the dfinity/ic pin.
  # 1. change the hash to the empty string ""
  # 2. run nix build .#drun
  # 3. copy the “expected” hash from the output into this file
  # 4. commit and push
  #
  # To automate this, .github/workflows/update-hash.yml has been
  # installed. You will normally not be bothered to perform
  # the command therein manually.

  cargoLock = {
    lockFile = "${pkgs.sources.ic-src}/Cargo.lock";
    outputHashes = {
      "build-info-0.0.27" = "sha256-SkwWwDNrTsntkNiCv6rsyTFGazhpRDnKtVzPpYLKF9U=";
      "cloudflare-0.12.0" = "sha256-67kQWJFRXZXHx+qwlyLa9NLF09b/4iRWxTLzCniCHZE=";
      "ic-bn-lib-0.1.0" = "sha256-2fw5kfGpvKr79dUo2onPnEVN1dYu275M6EOblMvgy88=";
      "ic-canister-sig-creation-1.1.0" = "sha256-c47Fh4kZbmezWCYVHMci2BMXJfESaOGsyNlWh8YR6oU=";
      "ic-gateway-0.2.0" = "sha256-NHnNRJABkuV0l0mvtAYjbQfUfAO2zuZMelrQdjvGlc0=";
      "ic-vetkeys-0.1.0" = "sha256-h8Jso21fK0QTyuSa14iAYsDvrfMphvI3spJBYOLgq1c=";
      "icrc1-test-env-0.1.1" = "sha256-2PB7e64Owin/Eji3k8UoeWs+pfDfOOTaAyXjvjOZ/4g=";
      "lmdb-rkv-0.14.99" = "sha256-5WcUzapkrc/s3wCBNCuUDhtbp17n67rTbm2rx0qtITg=";
    };
  };

  patchPhase = ''
    cd ../cargo-vendor-dir
    patch librocksdb-sys*/build.rs << EOF
    @@ -249,6 +249,9 @@ fn build_rocksdb() {
             config.flag("-Wno-missing-field-initializers");
             config.flag("-Wno-strict-aliasing");
             config.flag("-Wno-invalid-offsetof");
    +        if target.contains("darwin") {
    +            config.flag("-faligned-allocation");
    +        }
         }

         for file in lib_sources {
    EOF
    cd -

    mkdir -p .cargo
    cat > .cargo/config.toml << EOF
    [target.x86_64-apple-darwin]
    rustflags = [ "-C", "linker=c++" ]

    [target.aarch64-apple-darwin]
    rustflags = [ "-C", "linker=c++" ]
    EOF
  '';

  nativeBuildInputs = with pkgs; [
    pkg-config
    cmake
  ];

  buildInputs = with pkgs; [
    openssl
    llvm_18
    llvmPackages_18.libclang
    lmdb
    libunwind
    libiconv
  ] ++ pkgs.lib.optional pkgs.stdenv.isDarwin
    pkgs.darwin.apple_sdk.frameworks.Security;

  # needed for bindgen
  LIBCLANG_PATH = "${pkgs.llvmPackages_18.libclang.lib}/lib";
  CLANG_PATH = "${pkgs.llvmPackages_18.clang}/bin/clang";

  # needed for ic-protobuf
  PROTOC = "${pkgs.protobuf}/bin/protoc";

  doCheck = false;

  buildAndTestSubdir = "rs/drun";
}
