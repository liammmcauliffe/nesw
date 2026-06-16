/*
  Fish Shell Module

  Fish via Home Manager: abbreviations, rebuild helpers in functions/, and minimal
  interactive init. Tool hooks (eza, zoxide, fzf, broot, starship) come from HM modules.

  Exposes: (none - uses programs.fish from Home Manager)
  Depends: modules/shell/starship, modules/shell/tools
*/
{ ... }:
{
  programs.fish = {
    enable = true;

    shellAbbrs = {
      cat = "bat";
      lt = "eza --tree --icons";
      gs = "git status";
      gd = "git diff";
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
