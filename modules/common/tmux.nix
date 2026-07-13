{ ... }:
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -g allow-passthrough on
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
    '';
  };
}
