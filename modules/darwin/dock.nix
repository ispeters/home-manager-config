{
  config,
  lib,
  pkgs,
  ...
}:

let
  dockutil = "${pkgs.dockutil}/bin/dockutil";
  dockApps = [
    "${config.home.homeDirectory}/Applications/Home Manager Apps/iTerm2.app"
    "${config.home.homeDirectory}/Applications/Home Manager Apps/Google Chrome.app"
    "/System/Applications/Mail.app"
  ];
in
{
  home.activation.setDock = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${dockutil} --remove all --no-restart
    ${lib.concatMapStringsSep "\n" (app: ''${dockutil} --add "${app}" --no-restart'') dockApps}
    /usr/bin/killall Dock || true
  '';
}
