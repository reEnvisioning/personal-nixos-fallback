{ pkgs, ... }:
let
  shellQmlTemplate = builtins.readFile ./quickshell-config/shell.qml.template;
in {
  home.packages = with pkgs; [ quickshell ];

  xdg.configFile."quickshell/shell.qml.template".text = shellQmlTemplate;
}
