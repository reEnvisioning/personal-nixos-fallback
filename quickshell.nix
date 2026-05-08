{ pkgs, ... }:
{
    home.packages = with pkgs; [ quickshell ];

    xdg.configFile."quickshell/shell.qml".source = ./quickshell-config/shell.qml;
}
