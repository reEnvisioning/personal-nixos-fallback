{ inputs }:
inputs.nixpkgs.legacyPackages.x86_64-linux.mkShell {
  packages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
    nodejs_22
    corepack_22
    typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
  ];
}
