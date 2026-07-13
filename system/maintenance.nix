{ pkgs, hostname, ... }: {
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

  environment.systemPackages = with pkgs; [
    nvd

    (writeShellScriptBin "nr" ''
      set -euo pipefail
      FLAKE_DIR="/${hostname}"
      CMD="''${1:-}"
      ARG="''${2:-}"

      rebuild() {
        sudo nixos-rebuild switch --flake "$FLAKE_DIR#${hostname}"
      }

      case "$CMD" in
        "")
          read -rp "Wipe $FLAKE_DIR and rebuild from GitHub? [Y/n] " confirm
          case "$confirm" in
            ""|[Yy]*) ;;
            *) exit 0 ;;
          esac
          TMPDIR=$(mktemp -d)
          git clone --depth 1 https://github.com/reEnvisioning/personal-nixos-fallback.git "$TMPDIR"
          sudo rm -rf "$FLAKE_DIR"/*
          sudo cp -rf "$TMPDIR"/* "$FLAKE_DIR"/
          rm -rf "$TMPDIR"
          rebuild
          ;;
        update)
          if [ "$ARG" = "all" ]; then
            sudo nix flake update --flake "$FLAKE_DIR"
          else
            [ -n "$ARG" ] || { echo "Usage: nr update <input|all>"; exit 1; }
            sudo nix flake update "$ARG" --flake "$FLAKE_DIR"
          fi
          rebuild
          ;;
        rollback)
          COUNT=''${ARG:?Usage: nr rollback <count>}
          CURRENT=$(sudo nix-env --profile /nix/var/nix/profiles/system --list-generations \
                   | tail -1 | awk '{print $1}')
          TARGET=$((CURRENT - COUNT))
          [ "$TARGET" -ge 1 ] || { echo "Cannot go back $COUNT generations"; exit 1; }
          sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation "$TARGET"
          rebuild
          ;;
        collect)
          COUNT=''${ARG:-10}
          sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +"$COUNT"
          sudo nix-collect-garbage
          sudo nix store optimise
          ;;
        *)
          echo "Usage: nr [update <input|all>|rollback <count>|collect [<count>]]"
          exit 1
          ;;
      esac
    '')
  ];
}
