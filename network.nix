{
    pkgs,
    ...
}: {
    networking = {
        networkmanager.enable = true;
        firewall.enable = true;

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

    environment.systemPackages = with pkgs; [
        wireguard-tools
    ];
}
