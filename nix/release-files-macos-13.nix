{ self, pkgs }:
let
  common = import ./release-files-common.nix { inherit pkgs; };
  packages = self.packages.${pkgs.system};
in
pkgs.runCommandNoCC "motoko-release-${common.releaseVersion}" { } ''
  mkdir $out
  cp ${common.as_tarball "Darwin-x86_64" (with packages.release; [ mo-doc moc ])} $out/motoko-Darwin-x86_64-${common.releaseVersion}.tar.gz
'' 