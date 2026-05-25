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

    (writeShellScriptBin "nr" ''
      set -x

      THEME=''${1:-$(state get current-theme || echo void)}

      git clone https://github.com/reEnvisioning/personal-nixos-fallback.git
      sudo rm -rf /headspace/*
      sudo cp -rf ~/personal-nixos-fallback/* /headspace/
      rm -rf ~/personal-nixos-fallback
      sudo nixos-rebuild switch --flake /headspace#headspace
      switch-theme "$THEME"
    '')
  ];
}
