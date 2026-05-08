{ pkgs, ... }:
let
    theme = import ./theme.nix;
    shellQml = builtins.readFile ./quickshell-config/shell.qml;
    shellQmlContent = builtins.replaceStrings
        [ "@bg@" "@borderFocused@" "@fg@" ]
        [ theme.colors.bg theme.colors.borderFocused theme.colors.fg ]
        shellQml;
in {
    home.packages = with pkgs; [ quickshell ];

    xdg.configFile."quickshell/shell.qml".text = shellQmlContent;
}
