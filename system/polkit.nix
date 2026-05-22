{ pkgs, ... }: {
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.freedesktop.udisks2.") === 0 &&
          subject.isInGroup("disk")) {
        return polkit.Result.YES;
      }
    });
  '';
}
