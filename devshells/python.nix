{ inputs }:
inputs.nixpkgs.legacyPackages.x86_64-linux.mkShell {
  packages = with inputs.nixpkgs.legacyPackages.x86_64-linux; [
    python3
    uv
    ruff
    pyright
  ];
}
