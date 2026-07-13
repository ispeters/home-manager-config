{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      addKeysToAgent = "yes";
      identityFile = "~/.ssh/github";
    };
  };
}
