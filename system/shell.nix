{ pkgs, hostname, ... }: {
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nu" ''
      set -x

      FLAKE=''${1:-/${hostname}#${hostname}}
      FLAKE_DIR=''${FLAKE%%#*}

      sudo nix flake update "''${FLAKE_DIR}"
      sudo nixos-rebuild switch --flake "''${FLAKE}"

      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
      nix-collect-garbage
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

      TMPDIR=$(mktemp -d)
      git clone --depth 1 https://github.com/reEnvisioning/personal-nixos-fallback.git "$TMPDIR"
      sudo rm -rf "$FLAKE_DIR"/*
      sudo cp -rf "$TMPDIR"/* "$FLAKE_DIR"/
      rm -rf "$TMPDIR"
      sudo nixos-rebuild switch --flake "$FLAKE_DIR#${hostname}"
      switch-theme "$THEME"
    '')
  ];
}
