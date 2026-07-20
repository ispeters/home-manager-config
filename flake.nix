{
  description = "Ian's per-user configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      # this seems to generate warnings that I would prefer not to see
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";

    # reference my catalogue of language- and tool-specific devshells
    devshells.url = "github:ispeters/devshells";
    devshells.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixvim,
      mac-app-util,
      devshells,
      ...
    }:
    let
      # Claude provided this logic for checking whether we're running
      # on Darwin or NixOS; I don't understand it very well so I'm not
      # sure how it's supposed to be extended to support NixOS.
      system = "aarch64-darwin";
      isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeConfigurations.ianpetersen = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # this is a per-system flag indicating whether my shell.nix module
        # ought to install Bash as a user package or not. For now, it's
        # effectively hard-coded to true because the machines on which I'm
        # an administrator will all have a system-provided Bash, but I'm
        # leaving it here as a seam to make it possible to use my user
        # config on a system that does not provide Bash.
        extraSpecialArgs = {
          systemProvidesBash = true;
          inherit devshells;
        };
        modules = [
          nixvim.homeModules.nixvim
          mac-app-util.homeManagerModules.default
          ./home.nix
        ]
        ++ (if isDarwin then [ ./modules/darwin ] else [ ./modules/linux ]);
      };
    };
}
