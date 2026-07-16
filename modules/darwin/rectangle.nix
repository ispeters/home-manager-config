{ config, lib, pkgs, ... }:
{
  home.packages = [ pkgs.rectangle ];

  home.activation.rectangleLoginItem = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Bypass the on-launch prompt asking whether I'd prefer the Recommended
    # or Spectacle shortcuts and opt for Recommended.
    $DRY_RUN_CMD /usr/bin/defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true

    # Disable macOS's native edge-drag tiling so Rectangle (the more configurable,
    # already-declaratively-managed tool) is the sole handler of this gesture.
    $DRY_RUN_CMD /usr/bin/defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
    $DRY_RUN_CMD /usr/bin/defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false

    # Rectangle's own "launch at login" toggle calls SMAppService.mainApp
    # directly, which is self-referential and can't be driven from outside
    # the app — so we register it as a classic Login Item instead, which
    # works for any app and still shows up in System Settings.
    $DRY_RUN_CMD /usr/bin/osascript -e '
      tell application "System Events"
        if not (exists login item "Rectangle") then
          make login item at end with properties {path:"${config.home.homeDirectory}/Applications/Home Manager Apps/Rectangle.app", hidden:false}
        end if
      end tell
    '
  '';
}
