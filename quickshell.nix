{ pkgs, lib, ... }:
let
  theme = import ./theme.nix;
  shellQml = builtins.readFile ./quickshell-config/shell.qml;

  colorsQml = ''
pragma Singleton
import QtQuick

QtObject {
'' + lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "    readonly property color ${name}: \"${value}\"") theme.colors) + ''
}
'';
in {
  home.packages = with pkgs; [ quickshell ];

  xdg.configFile."quickshell/shell.qml".text = shellQml;
  xdg.configFile."quickshell/Colors.qml".text = colorsQml;
}
