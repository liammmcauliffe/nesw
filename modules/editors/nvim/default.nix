# treesitter parsers installed via nix — don't :TSInstall
{ pkgs, ... }:
let
  nvim-treesitter-plugins = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
    bash
    css
    dockerfile
    go
    html
    http
    javascript
    json
    lua
    markdown
    markdown_inline
    nix
    rust
    tsx
    typescript
  ]);
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      wl-clipboard
      lua-language-server
      nil
    ];

    plugins = with pkgs.vimPlugins; [
      vim-moonfly-colors
      friendly-snippets
      nvim-treesitter-plugins
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

  xdg.configFile."nvim" = {
    source = ./config;
    recursive = true;
  };
}
