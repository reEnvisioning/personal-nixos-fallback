{ pkgs, lib, config, username, ... }: {
  home = {
    stateVersion = "26.05";
    username = username;
    homeDirectory = "/home/${username}";
  };

  home.activation.setHomePermissions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    chmod 750 /home/${username}
    chown ${username}:${username} /home/${username}
  '';

  home.packages = with pkgs; [
    nodejs
    curl
    wget
    ripgrep
    fd
  ];

  home.file.".pi/agent/settings.json".text = builtins.toJSON {
    defaultModel = "gpt-4o";
    theme = "dark";
  };

  home.sessionPath = [ "/run/wrappers/bin" "/run/current-system/sw/bin" ];
}
