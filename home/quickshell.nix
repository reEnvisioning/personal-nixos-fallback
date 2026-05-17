{ pkgs, ... }:
let
  shellQml = builtins.readFile ../theme/resources/quickshell/shell.qml;
in {
  home.packages = with pkgs; [ quickshell ];

  xdg.configFile = {
    "quickshell/shell.qml".text = shellQml;
    "quickshell/lib".source = ../theme/resources/quickshell/lib;
    "quickshell/bar".source = ../theme/resources/quickshell/bar;
  };
}
