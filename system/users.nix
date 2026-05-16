{ pkgs, ... }: {
  users.users.visionary = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "vboxusers"
    ];
  };
}
