{
  description = "nesw by Liam McAuliffe";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, hyprland, home-manager, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # Change "main" if you want a different hostname
      nixosConfigurations.main = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hyprland; };
        modules = [
          ./hosts/main/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            # HARDCODE YOUR USERNAME HERE (e.g. "liam")
            home-manager.users."YOUR_USERNAME" = {
              imports = [ ./hosts/main/home.nix ];
              home.stateVersion = "26.05";
            };
          }
        ];
      };
    };
}
