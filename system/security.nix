{ lib, ... }: {
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.yama.ptrace_scope" = 1;
    "kernel.kexec_load_disabled" = 1;

    "kernel.randomize_va_space" = 2;
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
  };

  services.geoclue2.enable = lib.mkForce false;
}
