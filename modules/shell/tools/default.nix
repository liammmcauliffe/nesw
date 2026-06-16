/*
  Shell Utilities Module

  Modern CLI tools (eza, zoxide, bat, fzf, broot) via Home Manager with Fish
  integration. Replaces manual aliases and init scripts in config.fish.

  Exposes: (none)
  Depends: modules/shell/fish
*/
{ pkgs, ... }:
{
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd" "cd" ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
      paging = "always";
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--info=inline"
      "--preview 'bat --color=always {}'"
    ];
  };

  programs.broot = {
    enable = true;
    enableFishIntegration = true;
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    (writeShellScriptBin "kill-ui" ''
      echo "Killing Quickshell and Hyprland..."
      systemctl --user stop quickshell.service 2>/dev/null || true
      killall -9 Hyprland 2>/dev/null || true
    '')
  ];
}
