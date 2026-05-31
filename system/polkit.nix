{ pkgs, ... }: {
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
           action.id == "org.freedesktop.udisks2.filesystem-unmount" ||
           action.id == "org.freedesktop.udisks2.eject-media") &&
          subject.isInGroup("disk")) {
        try {
          var drive = action.lookup("drive");
          if (drive && drive.removable) {
            return polkit.Result.YES;
          }
        } catch (e) {}
      }
    });
  '';
}
