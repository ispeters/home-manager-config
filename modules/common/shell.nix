{ pkgs, systemProvidesBash ? false, ... }:
{
  programs.bash = {
    enable = true;
    package = if systemProvidesBash then null else pkgs.bashInteractive;
    initExtra = ''
      # doesn't need export because it's only used inside Bash
      PS1='\h:\W \u\$ '

      # this is exported because Claude isn't convinced it's safe
      # to not export it
      export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
      test -e ~/.iterm2_shell_integration.bash && source ~/.iterm2_shell_integration.bash || true
    '';
  };

  home.sessionVariables.EDITOR = "nvim";
}
