{ ... }: {
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-generations +20";
  };

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];

  services.fstrim.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';
}
