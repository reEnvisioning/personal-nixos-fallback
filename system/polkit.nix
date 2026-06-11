{ config, pkgs, lib, ... }:
let
  secretResult = builtins.tryEval (import ../secret.nix);
  hasSecret = secretResult.success;
in {
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
           action.id == "org.freedesktop.udisks2.filesystem-unmount" ||
           action.id == "org.freedesktop.udisks2.eject-media" ||
           action.id == "org.freedesktop.udisks2.filesystem-mount-other-seat") &&
          subject.isInGroup("disk")) {
        if (action.lookup("drive.removable") == "true") {
          return polkit.Result.YES;
        }
      }
    });

    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "wireguard-wg0.service" &&
          subject.user == "visionary") {
        return polkit.Result.YES;
      }
    });
  '';
}
