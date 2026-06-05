{ pkgs, ... }: {
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk ];
    config.common = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
  ];
}
