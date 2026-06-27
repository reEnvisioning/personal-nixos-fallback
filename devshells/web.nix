{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    nodejs_22
    corepack_22
    typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
  ];
}
