{ lib, username, ... }:
{
  home.activation.createSshControlDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p /home/${username}/.ssh/control
    chmod 700 /home/${username}/.ssh/control
  '';

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        ForwardAgent = "no";
        Compression = "yes";
        HashKnownHosts = "yes";
        ServerAliveInterval = "30";
        ServerAliveCountMax = "3";

        ControlMaster = "auto";
        ControlPath = "~/.ssh/control/%r@%h:%p";
        ControlPersist = "10m";

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

        LogLevel = "INFO";
      };
    };
  };
}
