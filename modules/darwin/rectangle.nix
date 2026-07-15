{ config, lib, pkgs, ... }:
{
  home.packages = [ pkgs.rectangle ];

  # Rectangle's own "launch at login" toggle calls SMAppService.mainApp
  # directly, which is self-referential and can't be driven from outside
  # the app — so we register it as a classic Login Item instead, which
  # works for any app and still shows up in System Settings.
  home.activation.rectangleLoginItem = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/osascript -e '
      tell application "System Events"
        if not (exists login item "Rectangle") then
          make login item at end with properties {path:"${config.home.homeDirectory}/Applications/Home Manager Apps/Rectangle.app", hidden:false}
        end if
      end tell
    '
  '';
}
