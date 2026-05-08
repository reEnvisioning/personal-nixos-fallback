{
    config,
    pkgs,
    lib,
    ...
}: {
    networking = {
        networkmanager.enable = true;
        firewall.enable = true;
        firewall.allowedTCPPorts = [ 53317 ];
        firewall.allowedUDPPorts = [ 53317 ];

        # Quad9 DNS configuration
        nameservers = [ "9.9.9.9" "149.112.112.112" ];

        # Wireguard configuration example (uncomment and configure as needed)
        # wireguard.interfaces.wg0 = {
        #     ips = ["10.0.0.1/24"];
        #     listenPort = 51820;
        #     privateKeyFile = "/path/to/private-key";
        #     peers = [
        #         {
        #             publicKey = "peer-public-key";
        #             allowedIPs = ["10.0.0.2/32"];
        #             endpoint = "peer.example.com:51820";
        #         }
        #     ];
        # };
    };

    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            PermitRootLogin = "no";
        };
    };

    # DNS over TLS with systemd-resolved
    services.resolved = {
        enable = true;
        fallbackDns = [ "9.9.9.9" "149.112.112.112" ];
        domains = [ "~." ];  # Use these DNS for all domains
    };

    environment.systemPackages = with pkgs; [
        wireguard-tools
    ];

    # Configure systemd-resolved to use DNS over TLS (DoT) for Quad9
    environment.etc."systemd/resolved.conf.d/quad9-dns.conf".text = ''
        [Resolve]
        DNS=9.9.9.9 149.112.112.112
        DNSOverTLS=yes
        Domains=~.
    '';

    # Tell NetworkManager to use systemd-resolved
    environment.etc."NetworkManager/conf.d/dns.conf".text = ''
        [device]
        dns=systemd-resolved
    '';
}
