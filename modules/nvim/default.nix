{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # add extra packages your neovim config relies on here (LSPs, formatters, etc.)
    extraPackages = with pkgs; [
      ripgrep
      fd
      wl-clipboard
      gcc
      gnumake
      lua-language-server
      nil
    ];

    # add neovim plugins here
    plugins = with pkgs.vimPlugins; [
      vim-moonfly-colors
      friendly-snippets
      nvim-treesitter
      nvim-lspconfig

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
