/*
  Starship Prompt Module

  Installs and enables the Starship cross-shell prompt with Fish integration.

  Exposes: (none — uses programs.starship from Home Manager)
  Depends: modules/shell/fish (enableFishIntegration)
*/
{ ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  xdg.configFile."starship.toml".source = ./starship.toml;
}
