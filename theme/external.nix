{ config, pkgs, lib, ... }:
let
  # Third-party app theme settings, based on mode (dark/light)
  # These are static configs that don't depend on specific theme colors
  externalThemes = {
    dark = {
      gtk = {
        theme = "Catppuccin-Mocha-Standard-Mauve-Dark";
        preferDark = true;
      };
      localsend = { color = "oled"; };
      obs = { style = "Acri"; };
      kde = { widgetStyle = "Fusion"; };
      qt = { style = "adwaita-dark"; };
      kdenlive = {
        scheme = "BreezeDark";
        widgetStyle = "Fusion";
      };
      gimp = {
        theme = "Default";
        colorScheme = "dark";
      };
      firefox = { darkMode = true; };
      librewolf = { darkMode = true; };
    };

    light = {
      gtk = {
        theme = "Catppuccin-Latte-Standard-Blue";
        preferDark = false;
      };
      localsend = { color = "system"; };
      obs = { style = "Light"; };
      kde = { widgetStyle = "Fusion"; };
      qt = { style = "Adwaita"; };
      kdenlive = {
        scheme = "BreezeLight";
        widgetStyle = "Fusion";
      };
      gimp = {
        theme = "Default";
        colorScheme = "light";
      };
      firefox = { darkMode = false; };
      librewolf = { darkMode = false; };
    };
  };

  # Helper to generate JSON from attribute set
  mkJson = name: data: {
    name = "reEnvisioning/external/${name}.json";
    value = {
      text = builtins.toJSON data;
      force = true;
    };
  };
in {
  # Export for use in hm.nix
  inherit externalThemes;

  # Generate external theme JSON files
  xdg.configFile = builtins.listToAttrs (lib.mapAttrsToList mkJson externalThemes);
}