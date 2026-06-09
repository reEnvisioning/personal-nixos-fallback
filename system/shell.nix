{ pkgs, hostname, ... }: {
  environment.systemPackages = with pkgs; [
    nvd
    (writeShellScriptBin "ng" ''
      set -x
      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
      nix-collect-garbage
    '')

    (writeShellScriptBin "nu" ''
      set -x

      FLAKE_DIR=''${1:-/${hostname}}

      sudo nix flake update "$FLAKE_DIR"
      sudo nixos-rebuild switch --flake "''${FLAKE_DIR}#${hostname}"

      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
      nix-collect-garbage
    '')

    (writeShellScriptBin "nu-stable" ''
      set -x
      sudo nix flake lock --update-input nixpkgs /${hostname}
      sudo nixos-rebuild switch --flake "/${hostname}#${hostname}"
      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
      nix-collect-garbage
    '')

    (writeShellScriptBin "nu-unstable" ''
      set -x
      sudo nix flake lock --update-input nixpkgs-unstable /${hostname}
      sudo nixos-rebuild switch --flake "/${hostname}#${hostname}"
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
      sudo cp /resources/secret.nix "$FLAKE_DIR"/
      rm -rf "$TMPDIR"
      sudo nixos-rebuild switch --flake "$FLAKE_DIR#${hostname}"
      switch-theme "$THEME"
    '')
  ];
}
