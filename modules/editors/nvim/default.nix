/*
  Neovim Editor Module

  Configures Neovim as the default editor with mini.* plugins, LSP tooling,
  and Tree-sitter parsers compiled declaratively via nixpkgs (no :TSInstall).

  Exposes: (none - uses programs.neovim from Home Manager)
  Depends: modules/themes (monospace font installed system-wide)
*/
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
