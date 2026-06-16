/*
  Fish Shell Module

  Fish via Home Manager: abbreviations, rebuild helpers in functions/, and minimal
  interactive init. Starship/zoxide/broot init comes from their HM modules.

  Exposes: (none — uses programs.fish from Home Manager)
  Depends: modules/shell/starship, modules/shell/tools
*/
{ ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      ls = "eza --icons";
      ll = "eza -la --icons --git";
      lt = "eza --tree --icons";
    };

    interactiveShellInit = ''
      set fish_greeting ""
    '';
  };

  xdg.configFile."fish/functions" = {
    source = ./functions;
    recursive = true;
  };
}
