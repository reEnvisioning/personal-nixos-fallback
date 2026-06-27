{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    nixpkgs-fmt
    statix
    deadnix
    nil
  ];
}
