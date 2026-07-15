# Declaratively configures iTerm2 to match the setup described in
# https://ispeters.bearblog.dev/setting-up-my-dev-environment-on-a-mac/
#
# This uses two different iTerm2 mechanisms, because iTerm2's settings are
# split across two tiers that are stored (and loaded) differently:
#
#   1. Per-profile settings (command, font, ligatures, italics, scrollback)
#      go in a "Dynamic Profile": a JSON file that iTerm2 reads directly
#      from ~/Library/Application Support/iTerm2/DynamicProfiles/ and
#      live-reloads on change. No import step required.
#
#   2. True global/Advanced settings aren't part of any profile and live in
#      iTerm2's main preferences plist instead. These have to be set with
#      `defaults write` against the com.googlecode.iterm2 domain. We do this
#      via home-manager activation scripts rather than by having Nix manage
#      the whole plist, because that plist also holds transient UI state
#      (window positions, recently used colors, etc.) that iTerm2 rewrites
#      on every quit -- mirroring the entire file would mean fighting iTerm2
#      over that churn on every launch.
#
# Naming: this module's profile is called "Personal" -- its salient
# property is that it's set up the way I actually want to work, not that
# it's Nix-managed (that may stop being a distinguishing feature if a
# rescue profile ends up in this repo too someday). iTerm2 ships a
# profile named "Default" out of the box; rather than have Nix collide
# with or take over that profile, it's kept as-is and manually renamed to
# "Rescue" -- a deliberately untouched fallback to use if "Personal" ever
# gets broken. "Personal" is made the actual startup default via the
# activation script below, so the star icon next to it in iTerm2's
# profile list is the real indicator of which one is default, not either
# name.
{ config, pkgs, ... }:
let
  # Fixed GUID for the Dynamic Profile so we can also reference it as the
  # default profile below. Generated once; must not change, or iTerm2 will
  # treat it as a new profile instead of updating this one.
  guid = "05B240E9-A86A-4296-9AF1-57DA084FE676";
in
{
  home.file."Library/Application Support/iTerm2/DynamicProfiles/home-manager.json".text =
    builtins.toJSON {
      "Profiles" = [
        {
          "Name" = "Personal";
          "Guid" = guid;
          "Custom Command" = "Yes";
          # No ssh-agent wrapper here: macOS's launchd-managed ssh-agent
          # already pins a single, stable SSH_AUTH_SOCK for the whole login
          # session, so tmux (and everything under it) inherits it for
          # free. Wrapping this command in `ssh-agent tmux ...` would spawn
          # a *separate*, empty agent scoped to this command instead --
          # losing access to whatever's loaded into the system agent via
          # Keychain, which defeats the point. That wrapper idiom only
          # earns its keep where there's no OS-provided session-wide agent
          # to begin with (e.g. bare Linux), which isn't the case here.
          #
          # tmux itself is Nix-managed, so we reference it via pkgs.tmux
          # rather than hardcoding the Homebrew path from the blog post.
          # This also means the path here tracks whatever tmux build is
          # currently active -- home-manager switch rewrites this file
          # automatically when that changes.
          #
          # Persistence note: this tmux server (and the system ssh-agent)
          # only survive as long as the underlying GUI session isn't torn
          # down. Locking the screen or Fast User Switching to another
          # account leaves the session running in the background, so the
          # tmux server (and anything ssh'd in remotely to reattach to it)
          # keeps going untouched -- this is the case relied on for
          # reattaching from another device. An actual logout, by
          # contrast, kills all foreground and background processes in
          # that session, tmux included, so this setup does NOT survive a
          # real logout. If that ever needs to change, tmux would have to
          # run outside the GUI session entirely (e.g. a LaunchDaemon or
          # the launchd "User" domain), which is a different mechanism
          # than starting it as this profile's command.

          # Note: going through tmux like this currently breaks FiraCode's
          #       ligatures in a way that annoys me, but I'm going with it
          #       for now.
          "Command" = "${pkgs.tmux}/bin/tmux -CC new -A -s main";
          "Use Italic Font" = true;
          # empirically determined by choosing the FiraCode option I want
          # in iTerm2's font-picker; the string provided by Claude didn't
          # work.
          "Normal Font" = "FiraCodeNF-Reg 13";
          "ASCII Ligatures" = true;
          "Non-ASCII Ligatures" = true;
          "Unlimited Scrollback" = true;
        }
      ];
    };

  # Dynamic Profiles are merely *available*; iTerm2 won't use one as the
  # startup default just because it exists, so we have to say so explicitly.
  home.activation.setItermDefaultProfile =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD /usr/bin/defaults write com.googlecode.iterm2 "Default Bookmark Guid" "${guid}"
    '';

  # Global (non-profile) iTerm2 preferences. Keys confirmed by diffing
  # `defaults read com.googlecode.iterm2` before/after toggling each setting
  # in the Preferences UI, since the on-disk keys don't always match the
  # Python API docs or the UI labels.
  home.activation.setItermGlobalPrefs =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # "Convert italics to reverse video in tmux integration?" in
      # Prefs > Advanced. Not part of any profile.
      $DRY_RUN_CMD /usr/bin/defaults write com.googlecode.iterm2 ConvertItalicsToReverseVideoForTmux -bool NO

      # "Use tmux profile" in Prefs > General > tmux. When true, all -CC
      # windows use an iTerm2-managed copy of the "Default" profile instead
      # of the profile of the connecting session, which silently drops
      # Personal's settings (e.g. FiraCode ligatures) inside tmux. false
      # makes -CC windows inherit the connecting session's profile instead.
      # On this machine the compiled-in default was "true" despite the key
      # being absent from defaults, so this must be pinned explicitly rather
      # than left unset.
      $DRY_RUN_CMD /usr/bin/defaults write com.googlecode.iterm2 TmuxUsesDedicatedProfile -bool false
    '';
}
