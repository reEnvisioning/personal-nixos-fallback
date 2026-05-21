{ pkgs, ... }: {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Force 48kHz sample rate (DaVinci Resolve requires this)
    extraConfig = {
      "10-default-sample-rate" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
        };
      };
    };
  };
}
