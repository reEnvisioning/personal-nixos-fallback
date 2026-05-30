{ config, pkgs, ... }: {
  programs.librewolf = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      settings = {
        "network.trr.mode" = 3;
        "network.trr.uri" = "https://dns.quad9.net/dns-query";
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.visibility" = "show";
      };
    };
  };
}
