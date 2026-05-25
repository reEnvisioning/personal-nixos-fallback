{ config, pkgs, inputs, lib, username, ... }: {
  home = {
    stateVersion = "25.11";
    username = username;
    homeDirectory = "/home/${username}";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    mpv
    prismlauncher
    localsend
    procps
    gimp
    jetbrains.idea-oss
    kdePackages.kdenlive
    libreoffice-qt
    obs-studio
    davinci-resolve-studio
    ocl-icd
  ];

  services.udiskie = {
    enable = true;
    settings = {
      program_options = {
        file_manager = "yazi";
      };
    };
  };

  # ── Wrapper scripts for network-allowed applications ──
  # Each wrapper launches the app via systemd-run --user --scope --slice=allowed,
  # placing it in the allowed cgroup so nftables permits its outbound traffic.
  # Any app NOT wrapped here is blocked from the network by default.
  home.file = builtins.listToAttrs (map (app: {
    name = ".local/bin/${app.name}";
    value = {
      executable = true;
      text = ''
        #!${pkgs.bash}/bin/bash
        exec ${pkgs.systemd}/bin/systemd-run --user --scope --slice=allowed \
          "${app.pkg}/bin/${app.binary or app.name}" "$@"
      '';
    };
  }) [
    { name = "firefox"; pkg = pkgs.firefox; }
    { name = "prismlauncher"; pkg = pkgs.prismlauncher; }
    { name = "localsend"; pkg = pkgs.localsend; }
    { name = "idea-oss"; pkg = pkgs.jetbrains.idea-oss; binary = "idea"; }
    { name = "davinci-resolve"; pkg = pkgs.davinci-resolve-studio; }
    { name = "VirtualBox"; pkg = pkgs.virtualbox; }
    { name = "VirtualBoxVM"; pkg = pkgs.virtualbox; binary = "VirtualBoxVM"; }
  ]);

  # Prepend ~/.local/bin to PATH so wrappers shadow originals
  home.sessionPath = [ ".local/bin" ];
}
