{ pkgs, nixUsers, trustedUsers ? nixUsers, cpuVendor, gpuVendor, pc ? "desktop", ... }:
let
  hw = import ../hardware/hardware.nix { inherit pc cpuVendor gpuVendor; };
  vbox-wrapped = pkgs.virtualbox.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      for bin in $out/bin/VirtualBox $out/bin/VirtualBoxVM $out/bin/VBoxSDL; do
        [[ -f "$bin" ]] && wrapProgram "$bin" --set QT_QPA_PLATFORM "xcb"
      done
    '';
  });
in
{
  imports = [
    ../network/networking.nix
    ./local.nix
    ../theme/plymouth.nix
    ./greeter.nix
    ./audio.nix
    ./compositor.nix
    ./polkit.nix
    ./security.nix
    ./sops.nix
    ./maintenance.nix
    ./power.nix
    ./mount.nix
  ] ++ hw.systemImports;

  system.stateVersion = "26.05";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    allowed-users = nixUsers;
    trusted-users = trustedUsers;
    require-sigs = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    openssh
    hyprshot
    brightnessctl
    tmux
  ];

  virtualisation.virtualbox.host = {
    enable = true;
    package = vbox-wrapped;
  };
}
