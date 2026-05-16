{ inputs }:
inputs.nixpkgs.legacyPackages.x86_64-linux.mkShell {
  packages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
    nixpkgs-fmt
    statix
    deadnix
    nil
  ];
}
