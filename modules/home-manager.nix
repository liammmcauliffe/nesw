{ config, lib, ... }:
{
  imports = [ ./nesw.nix ];

  options.nesw.home-manager.enable =
    lib.mkEnableOption "the nesw Home Manager module bundle";

  config = lib.mkIf config.nesw.home-manager.enable {
    nesw.enable = lib.mkDefault true;
  };
}
