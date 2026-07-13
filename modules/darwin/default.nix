{ pkgs, ... }:
{
  imports = [
    ./dock.nix
    ./iterm2.nix
    ./packages.nix
  ];
}
