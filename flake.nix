{
  description = "nesw by liam mcauliffe";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, hyprland, home-manager, zen-browser, quickshell, ... }:
    let
      system = "x86_64-linux";
      # change this to your system username before the first rebuild
      userName = "liam";
      host = import ./hosts/laptop;
    in
    {
      homeManagerModules = {
        nesw = import ./modules/home-manager.nix;
      };

      # change "main" if you want a different hostname
      nixosConfigurations.main = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hyprland userName; };
        modules = [
          host.configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs zen-browser quickshell hyprland; };
            home-manager.users.${userName} = {
              imports = [ host.home ];
              home.stateVersion = "26.05";
            };
          }
        ];
      };
    };
}
