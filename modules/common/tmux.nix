_: {
  programs.tmux = {
    enable = true;
    # enable focus-reporting in the terminal; this enables Neovim's
    # `autoread` feature, which checks files for on-disk changes
    # relative to buffer contents every time Neovim gains focus.
    focusEvents = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set-option -g allow-passthrough on
      # tell tmux the outer terminal supports 24-bit colour
      set-option -as terminal-features ",xterm-256color:RGB"
    '';
  };
}
