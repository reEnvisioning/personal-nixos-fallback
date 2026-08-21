{ pkgs, ... }:
{
  programs.yubikey-manager.enable = true;
  environment.systemPackages = [ pkgs.yubioath-flutter ];
}
