{ pkgs, ... }:
{
  home.packages = [ pkgs.age ];

  programs.password-store = {
    enable = true;
    package = pkgs.passage;
  };
}
