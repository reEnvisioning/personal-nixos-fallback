{ pkgs, ... }:
let
  shellQml = builtins.readFile ../theme/resources/quickshell/shell.qml;
in {
  home.packages = with pkgs; [ quickshell ];

  xdg.configFile = {
    "quickshell/shell.qml".text = shellQml;
    "quickshell/lib".source = ../theme/resources/quickshell/lib;
    "quickshell/bar".source = ../theme/resources/quickshell/bar;
    "quickshell/notif".source = ../theme/resources/quickshell/notif;
    "quickshell/user".source = ../theme/resources/user;
  };
}
