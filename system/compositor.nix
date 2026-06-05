{ pkgs, ... }: {
  programs.niri = {
    enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
  ];
}
