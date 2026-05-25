{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # Add extra packages your Neovim config relies on here (LSPs, formatters, etc.)
    extraPackages = with pkgs; [
      ripgrep
      fd
      wl-clipboard
    ];
  };

  xdg.configFile."nvim".source = ./config;
}
