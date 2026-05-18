{ pkgs, ... }:
let
  uiScale = "1"; # <- change this to scale up (e.g. 1.5, 2)

  shellQml = builtins.replaceStrings
    ["1 // scale-config"]
    ["${uiScale} // scale-config"]
    (builtins.readFile ../theme/resources/quickshell/shell.qml);
in {
  home.packages = with pkgs; [ quickshell libnotify ];

  xdg.configFile = {
    "quickshell/shell.qml".text = shellQml;
    "quickshell/lib".source = ../theme/resources/quickshell/lib;
    "quickshell/bar".source = ../theme/resources/quickshell/bar;
    "quickshell/notif".source = ../theme/resources/quickshell/notif;
    "quickshell/user".source = ../theme/resources/user;
  };
}
