{ pkgs, ... }:
{
  home.username = "ianpetersen";
  home.homeDirectory = "/Users/ianpetersen";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [
    ./modules/common/devshells.nix
    ./modules/common/editor.nix
    ./modules/common/git.nix
    ./modules/common/ripgrep.nix
    ./modules/common/shell.nix
    ./modules/common/ssh.nix
    ./modules/common/tmux.nix
  ];
}
