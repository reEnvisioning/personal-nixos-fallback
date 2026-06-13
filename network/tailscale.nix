{ ... }: {
  services.tailscale = {
    enable = true;
    openFirewall = false;
    disableUpstreamLogging = true;
    disableTaildrop = true;
    useRoutingFeatures = "none";
    extraSetFlags = [
      "--shields-up"
    ];
  };
}
