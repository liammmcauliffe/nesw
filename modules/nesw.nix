/*
  nesw — top-level Home Manager aggregator

  Single entry point for the full nesw module tree. Enable with:

    nesw.enable = true;

  Exposes: nesw.enable
  Depends: modules/themes, desktop, shell, terminal, editors, browser
*/
{ config, lib, ... }:
let
  cfg = config.nesw;
in
{
  options.nesw.enable = lib.mkEnableOption "the nesw desktop framework";

  config = lib.mkIf cfg.enable {
    imports = [
      ./themes
      ./desktop
      ./shell
      ./terminal
      ./editors
      ./browser
    ];
  };
}
