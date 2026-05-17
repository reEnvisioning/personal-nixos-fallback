{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "upgrade-system" ''
      set -x

      FLAKE=''${1:-/headspace#headspace}
      FLAKE_DIR=''${FLAKE%%#*}

      nix flake update "''${FLAKE_DIR}"
      nixos-rebuild switch --flake "''${FLAKE}"

      nix-collect-garbage --delete-older-than 30d

      files=$(ls -1t /nix/var/nix/profiles/system-*-link 2>/dev/null | head -2)
      if [ "$(echo "$files" | wc -l)" -ge 2 ]; then
        nvd diff $(echo "$files" | tail -2)
      fi
    '')
  ];
}
