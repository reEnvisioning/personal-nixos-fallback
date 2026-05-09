{ pkgs, ... }:
let
  shellQml = builtins.readFile ./quickshell-config/shell.qml;
in {
  home.packages = with pkgs; [ quickshell ];

  xdg.configFile."quickshell/shell.qml".text = shellQml;
}
