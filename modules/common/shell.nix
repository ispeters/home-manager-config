{ pkgs, systemProvidesBash ? false, ... }:
{
  programs.bash = {
    enable = true;
    package = if systemProvidesBash then null else pkgs.bashInteractive;
    initExtra = ''
      export BASH_SILENCE_DEPRECATION_WARNING=1
      export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
      test -e ~/.iterm2_shell_integration.bash && source ~/.iterm2_shell_integration.bash || true
    '';
  };

  home.sessionVariables.EDITOR = "nvim";
}
