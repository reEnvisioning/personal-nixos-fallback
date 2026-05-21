{ pkgs, ... }: {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig = {
      "context.properties" = {
        "default.clock.allowed-rates" = [ 48000 ];
      };
    };
  };
}
