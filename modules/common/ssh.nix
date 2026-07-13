{ ... }:
{
  # We deliberately do NOT enable home-manager's services.ssh-agent here and
  # instead rely on the ssh-agent macOS already runs via launchd. Reasoning:
  #
  #   - launchd starts it before any shell does, and pre-populates
  #     SSH_AUTH_SOCK in the environment of every process the OS launches --
  #     not just terminal sessions, but Xcode, Finder's "Clone in Terminal",
  #     VS Code's non-terminal git integration, etc. A Nix-managed agent
  #     only reaches processes that inherit *our shell's* environment, so
  #     GUI-launched tools would keep silently using Apple's agent anyway --
  #     that's a structural property of how macOS bootstraps GUI process
  #     environments, not something more Nix config can fix.
  #   - `ssh-add --apple-use-keychain` (an Apple patch, not upstream
  #     OpenSSH) lets a passphrase survive reboots via Keychain, with Touch
  #     ID unlock on newer hardware. Nix's openssh package doesn't carry
  #     this patch. Currently moot, since this key has no passphrase, but
  #     worth remembering if that changes.
  #
  # Trade-off: this isn't reproducible/version-pinned the way the rest of
  # this flake is, and it won't carry over to the future NixOS machine,
  # which will need home-manager's services.ssh-agent instead. Revisit if
  # a passphrase gets added or GUI/agent-sharing needs come up.
  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      addKeysToAgent = "yes";
      identityFile = "~/.ssh/github";
    };
  };
}
