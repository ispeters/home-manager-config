{ pkgs, systemProvidesBash ? false, ... }:
{
  programs.bash = {
    enable = true;
    package = if systemProvidesBash then null else pkgs.bashInteractive;
    initExtra = ''
      # doesn't need export because it's only used inside Bash
      PS1='\h:\W \u\$ '

      if [ "$LC_TERMINAL" = "iTerm2" ] && [ -e ~/.iterm2_shell_integration.bash ]; then
        export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
        source ~/.iterm2_shell_integration.bash || true
      fi
    '';
  };

  home.sessionVariables.EDITOR = "nvim";
}
