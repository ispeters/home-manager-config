{ pkgs, ... }:
{
  home.packages = with pkgs; [
    iterm2
    google-chrome
    signal-desktop
  ];
}
