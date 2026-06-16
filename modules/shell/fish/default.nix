/*
  Fish Shell Module

  Enables Fish with nesw rebuild helpers (`nswitch`, `ntest`, `nupdate`, `nrollback`) and eza aliases
  sourced from config.fish.

  Exposes: (none — uses programs.fish from Home Manager)
  Depends: modules/shell/starship (Fish integration for the prompt)
*/
{ ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./config.fish;
  };
}
