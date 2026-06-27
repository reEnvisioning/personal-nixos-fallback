{ pkgs, hostname, username, ... }: {
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-generations +20";
  };

  nix.optimise.automatic = true;
  nix.optimise.dates = ["weekly"];

  services.fstrim.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  services.udisks2.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    nvd

    (writeShellScriptBin "ng" ''
      set -xeuo pipefail

      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
      sudo -u ${username} nix-env --profile /nix/var/nix/profiles/per-user/${username}/profile --delete-generations +10 2>/dev/null || true
      sudo nix-collect-garbage
      sudo nix store optimise

      bootctl=$(which bootctl 2>/dev/null || echo /run/current-system/sw/bin/bootctl)
      if [ -x "$bootctl" ]; then
        "$bootctl" remove-old 2>/dev/null || true
      fi
    '')

    (writeShellScriptBin "nu" ''
      set -xeuo pipefail

      FLAKE_DIR=''${1:-/${hostname}}

      sudo nix flake update "$FLAKE_DIR"
      sudo nixos-rebuild switch --flake "''${FLAKE_DIR}#${hostname}"

      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
      nix-collect-garbage
    '')

    (writeShellScriptBin "nu-stable" ''
      set -xeuo pipefail
      sudo nix flake lock --update-input nixpkgs /${hostname}
      sudo nixos-rebuild switch --flake "/${hostname}#${hostname}"
      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
      nix-collect-garbage
    '')

    (writeShellScriptBin "nu-unstable" ''
      set -xeuo pipefail
      sudo nix flake lock --update-input nixpkgs-unstable /${hostname}
      sudo nixos-rebuild switch --flake "/${hostname}#${hostname}"
      sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +10
      nix-collect-garbage
    '')

    (writeShellScriptBin "nr" ''
      set -xeuo pipefail

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
      git clone --depth 1 https://github.com/reEnvisioning/personal-nixos-fallback.git "$TMPDIR" || {
        echo "FATAL: git clone failed, aborting"
        rm -rf "$TMPDIR"
        exit 1
      }
      sudo rm -rf "$FLAKE_DIR"/*
      sudo cp -rf "$TMPDIR"/* "$FLAKE_DIR"/
      sudo cp /resources/secret.nix "$FLAKE_DIR"/
      sudo install -d -m 0700 /etc/wireguard
      for f in private.key psk.key; do
        [ -f "/resources/wireguard/$f" ] && sudo cp "/resources/wireguard/$f" /etc/wireguard/ && sudo chmod 0600 "/etc/wireguard/$f"
      done
      rm -rf "$TMPDIR"
      sudo nixos-rebuild switch --flake "$FLAKE_DIR#${hostname}"
      switch-theme "$THEME"
    '')
  ];
}
