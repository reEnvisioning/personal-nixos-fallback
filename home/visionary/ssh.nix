{ ... }: {
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = false;
        compression = true;
        hashKnownHosts = true;
        serverAliveInterval = 30;
        serverAliveCountMax = 3;

        controlMaster = "auto";
        controlPath = "~/.ssh/control/%r@%h:%p";
        controlPersist = "10m";

        extraOptions = {
          KexAlgorithms = "sntrup761x25519-sha512@openssh.com,diffie-hellman-group-exchange-sha256";
          Ciphers = "chacha20-poly1305@openssh.com,aes256-gcm@openssh.com";
          MACs = "hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com";
          HostKeyAlgorithms = "ssh-ed25519-cert-v01@openssh.com,ssh-ed25519";
          PubkeyAcceptedAlgorithms = "ssh-ed25519";

          PasswordAuthentication = "no";
          KbdInteractiveAuthentication = "no";
          ChallengeResponseAuthentication = "no";

          ForwardX11 = "no";
          ForwardX11Trusted = "no";

          RekeyLimit = "1G 1h";
          StrictHostKeyChecking = "ask";
          UpdateHostKeys = "ask";

          UserKnownHostsFile = "~/.ssh/known_hosts";

          LogLevel = "VERBOSE";
        };
      };
    };
  };
}
