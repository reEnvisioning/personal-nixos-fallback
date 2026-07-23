{ pkgs, lib, config, username, unstable, ... }:
let
  sandboxed-pi = pkgs.symlinkJoin {
    name = "pi-sandboxed";
    paths = [ unstable.pi-coding-agent ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/pi \
        --set PATH "/run/wrappers/bin:/run/current-system/sw/bin" \
        --set PI_CODING_AGENT_DIR "${config.home.homeDirectory}/.pi/agent"
    '';
  };
in {
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
    sandboxed-pi
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
