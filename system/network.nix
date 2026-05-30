{
  config,
  pkgs,
  lib,
  hostname,
  ...
}: {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 53317 ];
    firewall.allowedUDPPorts = [ 53317 ];
  };

  networking.networkmanager.dns = "systemd-resolved";

  networking.networkmanager.settings.main = {
    connection-check-interval = 0;
    "wifi.scan-rand-mac-address" = true;
  };

  networking.nftables.enable = true;
  networking.nftables.ruleset = ''
    # Existing DNS filter — blocks direct DNS to non-localhost
    table inet dns-filter {
      chain output {
        type filter hook output priority filter + 1; policy accept;
        udp dport 53 ip daddr 127.0.0.0/8 accept
        udp dport 53 ip6 daddr ::1 accept
        udp dport 53 reject
        tcp dport 53 ip daddr 127.0.0.0/8 accept
        tcp dport 53 ip6 daddr ::1 accept
        tcp dport 53 reject
      }
    }
  '';

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban.enable = true;

  services.opensnitch = {
    enable = true;
    settings = {
      DefaultAction = "deny";
      InterceptUnknown = true;
      ProcMonitorMethod = "ebpf";
      Firewall = "nftables";
      LogLevel = 1;
    };
    rules = {
      # System services — always allow
      systemd-resolved = {
        name = "systemd-resolved";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*/lib/systemd/systemd-resolved$";
        };
      };
      NetworkManager = {
        name = "NetworkManager";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*/bin/NetworkManager$";
        };
      };
      nix-daemon = {
        name = "nix-daemon";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*/bin/nix-daemon$";
        };
      };
      nix = {
        name = "nix";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*/bin/nix$";
        };
      };
      sshd = {
        name = "sshd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*/bin/sshd$";
        };
      };
      systemd-timesyncd = {
        name = "systemd-timesyncd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.path";
          data = "^/nix/store/.*/lib/systemd/systemd-timesyncd$";
        };
      };

      # User apps
      firefox = {
        name = "firefox";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.name";
          data = "^firefox";
        };
      };
      git = {
        name = "git";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          sensitive = false;
          operand = "process.name";
          data = "^git$";
        };
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
      DNSOverTLS = true;
      Domains = [ "~." ];
    };
  };

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
