{ pkgs, ... }: {
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
  '';
}
