{ pkgs, hostname, ... }: {
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nu" ''
      set -x

      FLAKE=''${1:-/${hostname}#${hostname}}
      FLAKE_DIR=''${FLAKE%%#*}

      nix flake update "''${FLAKE_DIR}"
      nixos-rebuild switch --flake "''${FLAKE}"

      nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
      nix-collect-garbage

      files=$(ls -1t /nix/var/nix/profiles/system-*-link 2>/dev/null | head -2)
      if [ "$(echo "$files" | wc -l)" -ge 2 ]; then
        nvd diff $(echo "$files" | tail -2)
      fi
    '')

    (writeShellScriptBin "nr" ''
      set -x

      THEME=''${1:-$(state get current-theme || echo void)}

      if [ -z "${hostname}" ]; then
        echo "FATAL: hostname is empty, aborting"
        exit 1
      fi

      FLAKE_DIR="/${hostname}"

      if [ ! -f "$FLAKE_DIR/flake.nix" ]; then
        echo "FATAL: $FLAKE_DIR does not contain flake.nix, aborting"
        exit 1
      fi

      git clone https://github.com/reEnvisioning/personal-nixos-fallback.git
      sudo rm -rf "$FLAKE_DIR"/*
      sudo cp -rf ~/personal-nixos-fallback/* "$FLAKE_DIR"/
      sudo nixos-rebuild switch --flake "$FLAKE_DIR#${hostname}"
      switch-theme "$THEME"
    '')
  ];
}
