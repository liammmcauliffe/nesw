{ config, lib, ... }:
let
  cfg = config.nesw;
in
{
  options.nesw.enable = lib.mkEnableOption "nesw";

  config = lib.mkIf cfg.enable {
    imports = [
      ./desktop
      ./shell
      ./terminal
      ./editors
      ./browser
    ];
  };
}
