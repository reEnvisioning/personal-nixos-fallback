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
      DefaultAction = "reject";
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
          type = "simple";
          operand = "process.path";
          data = "${pkgs.systemd}/lib/systemd/systemd-resolved";
        };
      };
      NetworkManager = {
        name = "NetworkManager";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.networkmanager}/bin/NetworkManager";
        };
      };
      nix-daemon = {
        name = "nix-daemon";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.nix}/bin/nix-daemon";
        };
      };
      sshd = {
        name = "sshd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.openssh}/bin/sshd";
        };
      };
      systemd-timesyncd = {
        name = "systemd-timesyncd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.systemd}/lib/systemd/systemd-timesyncd";
        };
      };

      # User apps
      firefox = {
        name = "firefox";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.firefox}/bin/firefox";
        };
      };
      prismlauncher = {
        name = "prismlauncher";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.prismlauncher}/bin/prismlauncher";
        };
      };
      localsend = {
        name = "localsend";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.localsend}/bin/localsend";
        };
      };
      idea-oss = {
        name = "idea-oss";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.jetbrains.idea-oss}/bin/idea";
        };
      };
      davinci-resolve = {
        name = "davinci-resolve";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.davinci-resolve-studio}/bin/davinci-resolve";
        };
      };
      virtualbox = {
        name = "virtualbox";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          operand = "process.path";
          data = "${pkgs.virtualbox}/bin/VirtualBox";
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
