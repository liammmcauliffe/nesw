/*
  nesw Home Manager export

  Import this module from your flake via homeManagerModules.nesw:

    imports = [ inputs.nesw.homeManagerModules.nesw ];
    nesw.home-manager.enable = true;

  Or enable the bundle directly:

    imports = [ inputs.nesw.homeManagerModules.nesw ];
    nesw.enable = true;
*/
{ config, lib, ... }:
{
  imports = [ ./nesw.nix ];

  options.nesw.home-manager.enable =
    lib.mkEnableOption "the nesw Home Manager module bundle";

  config = lib.mkIf config.nesw.home-manager.enable {
    nesw.enable = lib.mkDefault true;
  };
}
