/*
  Starship Prompt Module

  Installs Starship and enables Fish integration via Home Manager.
  Config: modules/shell/starship/starship.toml → ~/.config/starship.toml

  Exposes: (none - uses programs.starship from Home Manager)
  Depends: modules/shell/fish
*/
{ ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;
}
