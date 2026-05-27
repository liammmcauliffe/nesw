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

    # Add you Neovim plugins here
    plugins = with pkgs.vimPlugins; [
        vim-moonfly-colors
        friendly-snippets

        mini-files
        mini-notify
        mini-cmdline
        mini-surround 
        mini-pick
        mini-extra
        mini-completion
        mini-snippets
    ];
  };

  xdg.configFile."nvim".source = ./config;
}
