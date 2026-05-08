{ pkgs, ... }:
let
    theme = import ./theme.nix;
    shellQml = builtins.readFile ./quickshell-config/shell.qml;
    shellQmlContent = builtins.replaceStrings
        [ "@background@" "@borderFocused@" "@text@" ]
        [ theme.colors.background theme.colors.borderFocused theme.colors.text ]
        shellQml;
in {
    home.packages = with pkgs; [ quickshell ];

    xdg.configFile."quickshell/shell.qml".text = shellQmlContent;
}
