{ ... }: {
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "ai-agent") {
        if (action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hibernate" ||
            action.id == "org.freedesktop.login1.hibernate-multiple-sessions" ||
            action.id == "org.freedesktop.login1.suspend" ||
            action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
            action.id == "org.freedesktop.login1.sleep" ||
            action.id == "org.freedesktop.login1.sleep-multiple-sessions" ||
            action.id == "org.freedesktop.systemd1.reboot" ||
            action.id == "org.freedesktop.systemd1.poweroff" ||
            action.id == "org.freedesktop.hostname1.set-static-hostname" ||
            action.id == "org.freedesktop.hostname1.set-hostname") {
          return polkit.Result.NO;
        }
        if (action.id == "org.freedesktop.systemd1.manage-units") {
          var unit = action.lookup("unit");
          if (unit && (
            unit.endsWith("shutdown.target") ||
            unit.endsWith("reboot.target") ||
            unit.endsWith("poweroff.target") ||
            unit.endsWith("halt.target") ||
            unit.endsWith("sleep.target") ||
            unit.endsWith("hibernate.target") ||
            unit.endsWith("hybrid-sleep.target") ||
            unit.endsWith("suspend.target") ||
            unit.endsWith("systemd-logind.service") ||
            unit.endsWith("nix-daemon.service")
          )) {
            return polkit.Result.NO;
          }
        }
      }
    });
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "ai-agent") {
        var unit = action.lookup("unit");
        if (unit && unit.startsWith("run-") && (unit.endsWith(".scope") || unit.endsWith(".service"))) {
          return polkit.Result.YES;
        }
      }
    });
  '';
}
