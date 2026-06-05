{ pkgs, ... }: {
  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gnome xdg-desktop-portal-gtk ];
    config.niri."org.freedesktop.impl.portal.FileChooser" = "nautilus";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
    (runCommandLocal "nautilus-portal" { } ''
      mkdir -p $out/share/xdg-desktop-portal/portals
      cat > $out/share/xdg-desktop-portal/portals/nautilus.portal <<EOF
      [portal]
      DBusName=org.gnome.Nautilus
      Interfaces=org.freedesktop.impl.portal.FileChooser
      EOF
    '')
  ];
}
