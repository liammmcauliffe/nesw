/*
  Shell Utilities Module

  Adds everyday CLI tools (eza, zoxide, broot) with Fish shell integration.

  Exposes: (none)
  Depends: modules/shell/fish (Fish integration for zoxide and broot)
*/
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    eza
  ];

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
  };
}
