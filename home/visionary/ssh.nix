{ ... }: {
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    forwardAgent = false;

    controlMaster = "auto";
    controlPath = "~/.ssh/control/%r@%h:%p";
    controlPersist = "10m";

    extraConfig = ''
      KexAlgorithms sntrup761x25519-sha512@openssh.com,diffie-hellman-group-exchange-sha256
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
      MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
      HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-ed25519
      PubkeyAcceptedAlgorithms ssh-ed25519

      PasswordAuthentication no
      KbdInteractiveAuthentication no
      ChallengeResponseAuthentication no
      GSSAPIAuthentication no
      PreferredAuthentications publickey

      ForwardAgent no
      ForwardX11 no
      ForwardX11Trusted no
      AllowTcpForwarding no
      AllowStreamLocalForwarding no
      Tunnel no

      RekeyLimit 1G 1h

      StrictHostKeyChecking ask
      UpdateHostKeys ask

      ServerAliveInterval 30
      ServerAliveCountMax 3

      LogLevel VERBOSE
    '';
  };
}
