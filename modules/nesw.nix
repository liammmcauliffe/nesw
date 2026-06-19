{ config, lib, ... }:
let
  cfg = config.nesw;
in
{
  imports = lib.optionals cfg.enable [
    ./desktop
    ./shell
    ./terminal
    ./editors
    ./browser
  ];

  options.nesw.enable = lib.mkEnableOption "nesw";
}
