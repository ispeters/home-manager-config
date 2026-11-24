{ lib, pkgs, ... }:

let
  # nixpkgs' mattermost-desktop is marked broken on Darwin
  # (https://github.com/NixOS/nixpkgs/issues/430763), so I repackage
  # upstream's signed DMG instead. Updating means bumping `version` and
  # `hash` by hand.
  mattermost = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "mattermost-desktop";
    version = "6.4.0";

    src = pkgs.fetchurl {
      url = "https://github.com/mattermost/desktop/releases/download/v${finalAttrs.version}/mattermost-desktop-${finalAttrs.version}-mac-arm64.dmg";
      hash = "sha256-fyj86Hxj7Iaff10M9dp6CKyuF+B5qHi3WhKE6pKvLfA=";
    };

    nativeBuildInputs = [ pkgs.undmg ];
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -R Mattermost.app $out/Applications/
      runHook postInstall
    '';

    # leave the bundle untouched so upstream's code signature stays valid
    dontFixup = true;

    meta = {
      description = "Mattermost Desktop client";
      homepage = "https://mattermost.com/";
      license = lib.licenses.asl20;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "aarch64-darwin" ];
    };
  });
in
{
  home.packages = [ mattermost ];
}
