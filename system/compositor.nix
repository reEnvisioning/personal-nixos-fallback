{ pkgs, ... }: {
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
