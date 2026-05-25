{pkgs, nixUsers, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./network.nix
    ./desktop.nix
    ./local.nix
    ./luks.nix
    ./plymouth.nix
    ./boot.nix
    ./greeter.nix
    ./bluetooth.nix
    ./audio.nix
    ./compositor.nix
    ./virtualisation.nix
    ./polkit.nix
    ./security.nix
    ./shell.nix
  ];

  system.stateVersion = "25.11";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    allowed-users = nixUsers;
    trusted-users = nixUsers;
    auto-optimise-store = false;

  };

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-generations +10";
  };

  nix.optimise.automatic = true;
  nix.optimise.dates = ["weekly"];
  services.udisks2.enable = true;
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    hyprshot
    pavucontrol
    brightnessctl
    temurin-bin-21
  ];

}
