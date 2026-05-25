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
      settings = import ./settings.nix;
      system = "x86_64-linux";
      # Account from the NixOS installer; set when you run sudo nixos-rebuild
      installUser =
        let u = builtins.getEnv "SUDO_USER";
        in if u != "" then u else builtins.getEnv "USER";
    in
    {
      nixosConfigurations.${settings.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hyprland installUser; };
        modules = [
          ./hosts/main/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
          ({ lib, ... }:
            lib.mkIf (installUser != "") {
              home-manager.users.${installUser} = {
                imports = [ ./hosts/main/home.nix ];
                home.stateVersion = "26.05";
              };
            })
        ];
      };
    };
}
