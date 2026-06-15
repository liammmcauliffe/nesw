{
  description = "nesw by liam mcauliffe";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = { nixpkgs, hyprland, home-manager, zen-browser, quickshell, ... }:
    let
      system = "x86_64-linux";
      # change this to your system username before the first rebuild
      userName = "liam";
    in
    {
      # change "main" if you want a different hostname
      nixosConfigurations.main = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hyprland userName; };
        modules = [
          ./hosts/main/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit zen-browser quickshell; };
            home-manager.users.${userName} = {
              imports = [ ./hosts/main/home.nix ];
              home.stateVersion = "26.05";
            };
          }
        ];
      };
    };
}
