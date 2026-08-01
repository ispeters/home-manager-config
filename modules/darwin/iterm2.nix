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

  # Vendored from https://github.com/gnachman/iTerm2-shell-integration, the
  # small repo iTerm2's shell integration scripts now live in (split out of
  # the main app repo). Pinned by hash rather than curled at
  # activation/shell-startup time so a change upstream shows up as an
  # explicit hash mismatch instead of silently changing what gets sourced.
  # shell.nix's bash initExtra already sources this file if present; this
  # is what makes it actually present.
  itermShellIntegrationBash = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/gnachman/iTerm2-shell-integration/main/shell_integration/bash";
    hash = "sha256-yHVNnDW8JJNL56sgc1ZRyaAZvStELr+0HZED5i6VxbA=";
  };
in
{
  home = {
    file = {
      "Library/Application Support/iTerm2/DynamicProfiles/home-manager.json".text = builtins.toJSON {
        "Profiles" = [
          {
            # Vercel theme, pulled directly from the .itermcolors source
            # rather than transcribed by hand from a screenshot --
            # https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/Vercel.itermcolors
            # Same key names/shape as Badge Color below; this is what
            # "Copy Profile as JSON" from iTerm2 itself would have
            # produced, just sourced from the upstream file instead so
            # there's no manual color-picker step to get it into Personal.
            "Ansi 0 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0;
              "Green Component" = 0;
              "Blue Component" = 0;
              "Alpha Component" = 1;
            };
            "Ansi 1 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9882;
              "Green Component" = 0;
              "Blue Component" = 0.2118;
              "Alpha Component" = 1;
            };
            "Ansi 2 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.1608;
              "Green Component" = 0.6627;
              "Blue Component" = 0.2824;
              "Alpha Component" = 1;
            };
            "Ansi 3 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 1;
              "Green Component" = 0.6824;
              "Blue Component" = 0;
              "Alpha Component" = 1;
            };
            "Ansi 4 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0;
              "Green Component" = 0.4157;
              "Blue Component" = 1;
              "Alpha Component" = 1;
            };
            "Ansi 5 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9529;
              "Green Component" = 0.1569;
              "Blue Component" = 0.5098;
              "Alpha Component" = 1;
            };
            "Ansi 6 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0;
              "Green Component" = 0.6745;
              "Blue Component" = 0.5882;
              "Alpha Component" = 1;
            };
            "Ansi 7 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9961;
              "Green Component" = 1;
              "Blue Component" = 1;
              "Alpha Component" = 1;
            };
            "Ansi 8 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.6588;
              "Green Component" = 0.6588;
              "Blue Component" = 0.6588;
              "Alpha Component" = 1;
            };
            "Ansi 9 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 1;
              "Green Component" = 0.502;
              "Blue Component" = 0.502;
              "Alpha Component" = 1;
            };
            "Ansi 10 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.2941;
              "Green Component" = 0.8824;
              "Blue Component" = 0.3647;
              "Alpha Component" = 1;
            };
            "Ansi 11 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 1;
              "Green Component" = 0.6824;
              "Blue Component" = 0;
              "Alpha Component" = 1;
            };
            "Ansi 12 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.2863;
              "Green Component" = 0.6824;
              "Blue Component" = 1;
              "Alpha Component" = 1;
            };
            "Ansi 13 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9765;
              "Green Component" = 0.4941;
              "Blue Component" = 0.6588;
              "Alpha Component" = 1;
            };
            "Ansi 14 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0;
              "Green Component" = 0.8941;
              "Blue Component" = 0.7686;
              "Alpha Component" = 1;
            };
            "Ansi 15 Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9961;
              "Green Component" = 0.9961;
              "Blue Component" = 0.9961;
              "Alpha Component" = 1;
            };
            "Background Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.0627;
              "Green Component" = 0.0627;
              "Blue Component" = 0.0627;
              "Alpha Component" = 1;
            };
            "Bold Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9804;
              "Green Component" = 0.9804;
              "Blue Component" = 0.9804;
              "Alpha Component" = 1;
            };
            "Cursor Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9529;
              "Green Component" = 0.1569;
              "Blue Component" = 0.5098;
              "Alpha Component" = 1;
            };
            "Cursor Guide Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9804;
              "Green Component" = 0.9804;
              "Blue Component" = 0.9804;
              "Alpha Component" = 1;
            };
            "Cursor Text Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9804;
              "Green Component" = 0.9804;
              "Blue Component" = 0.9804;
              "Alpha Component" = 1;
            };
            "Foreground Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9804;
              "Green Component" = 0.9804;
              "Blue Component" = 0.9804;
              "Alpha Component" = 1;
            };
            "Selected Text Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.9804;
              "Green Component" = 0.9804;
              "Blue Component" = 0.9804;
              "Alpha Component" = 1;
            };
            "Selection Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0;
              "Green Component" = 0.3569;
              "Blue Component" = 0.9059;
              "Alpha Component" = 1;
            };
            "ASCII Ligatures" = true;
            # Chosen by eye in iTerm2's own color picker against this
            # profile's actual black background/white text, R:69 G:147
            # B:252 A:71 on a 0-255 slider. Composites (apparent =
            # raw*alpha, since background is black) to roughly
            # rgb(19,41,70) -- hue ~214 degrees, ~57% saturation, ~17%
            # lightness: a fairly dark, subdued navy. Saturation nearly
            # doubled versus the earlier solved-for color (which was
            # ~34%), which is what actually fixed the "reads too red"
            # complaint -- that one wasn't hue-shifted toward red, it was
            # just under-saturated/washed-out enough to look gray-ish
            # next to the fully-saturated ANSI blue in the PS1 dot.
            "Badge Color" = {
              "Color Space" = "sRGB";
              "Red Component" = 0.2706;
              "Green Component" = 0.5765;
              "Blue Component" = 0.9882;
              "Alpha Component" = 0.2784;
            };
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
            "Command" = "${pkgs.tmux}/bin/tmux -CC new -A -s main";
            "Custom Command" = "Yes";
            "Guid" = guid;
            "Name" = "Personal";
            "Non-ASCII Ligatures" = true;
            # empirically determined by choosing the FiraCode option I want
            # in iTerm2's font-picker; the string provided by Claude didn't
            # work.
            "Normal Font" = "FiraCodeNF-Reg 13";
            # Enable Opt-F and Opt-B at the shell prompt to move back and
	    # forth by words rather than sending composed characters.
            "Option Key Sends" = 2; # Left Option → Esc+
            "Unlimited Scrollback" = true;
            "Use Italic Font" = true;
          }
        ];
      };

      ".iterm2_shell_integration.bash".source = itermShellIntegrationBash;
    };

    activation = {
      # Dynamic Profiles are merely *available*; iTerm2 won't use one as the
      # startup default just because it exists, so we have to say so explicitly.
      setItermDefaultProfile = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD /usr/bin/defaults write com.googlecode.iterm2 "Default Bookmark Guid" "${guid}"
      '';

      # Global (non-profile) iTerm2 preferences. Keys confirmed by diffing
      # `defaults read com.googlecode.iterm2` before/after toggling each setting
      # in the Preferences UI, since the on-disk keys don't always match the
      # Python API docs or the UI labels.
      setItermGlobalPrefs = config.lib.dag.entryAfter [ "writeBoundary" ] ''
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

        # "New Window or Tab from tmux" dialog, shown on Cmd+N inside a tmux
        # integration session (ambiguous: native window vs. tmux window).
        # true = always treat it as a request for a new tmux window and never
        # ask. Key confirmed by diffing defaults before/after checking
        # "Remember my choice" > "New tmux Window".
        $DRY_RUN_CMD /usr/bin/defaults write com.googlecode.iterm2 NoSyncNewWindowOrTabFromTmuxOpensTmux -bool true

        # "Automatically bury the tmux client session after connecting" in
        # Prefs > General > tmux. When true, the window that's running the
        # tmux client gets hidden until the last tmux window's shell ends.
        $DRY_RUN_CMD /usr/bin/defaults write com.googlecode.iterm2 AutoHideTmuxClientSession -bool true

        # Prefer "Dark" them in Prefs > Appearance > General. It appears to
        # be an enumerated list, and "Dark" is at index 1.
        $DRY_RUN_CMD /usr/bin/defaults write com.googlecode.iterm2 TabStyleWithAutomaticOption 1
      '';
    };
  };
}
