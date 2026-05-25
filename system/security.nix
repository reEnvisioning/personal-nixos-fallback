{ lib, ... }: {
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.yama.ptrace_scope" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.tcp_syncookies" = 1;
    "kernel.kexec_load_disabled" = 1;
    "net.ipv6.conf.all.use_tempaddr" = lib.mkForce "2";
    "net.ipv6.conf.default.use_tempaddr" = lib.mkForce "2";
  };

  services.geoclue2.enable = lib.mkDefault false;
}
