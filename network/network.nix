let
  secretResult = builtins.tryEval (import ../secret.nix);
  hasSecret = secretResult.success;
in {
  inherit hasSecret;
  secrets = if hasSecret then secretResult.value else {};

  dns = {
    servers = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
    doT = true;
    domains = [ "~." ];
  };

  firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    settings = {
      main = {
        connection-check-interval = 0;
        "wifi.scan-rand-mac-address" = true;
      };
    };
  };
}
