{ pkgs, nixUsers, ... }:
let
  hw = import ../hardware/hardware.nix;
in {
  imports = [
    ../network/networking.nix
    ./local.nix
    ../theme/plymouth.nix
    ./boot.nix
    ./greeter.nix
    ./audio.nix
    ./compositor.nix
    ./polkit.nix
    ./security.nix
    ./maintenance.nix
  ] ++ hw.systemImports;

  system.stateVersion = "26.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    allowed-users = nixUsers;
    trusted-users = nixUsers;
    require-sigs = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    openssh
    hyprshot
    pavucontrol
    brightnessctl
    temurin-bin-21
    tmux
  ];

  virtualisation.virtualbox.host.enable = true;
}