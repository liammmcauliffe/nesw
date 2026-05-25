{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghostty
  ];

  xdg.configFile."ghostty/config".text = ''
    theme = "Vague"
    font-family = "JetBrainsMono NFM Regular"
    font-size = 14
    window-padding-x = 4
    window-padding-y = 4
    window-decoration = true
    cursor-style=block
    adjust-cell-height=35%
    mouse-scroll-multiplier = 2
    window-colorspace = "display-p3"
    copy-on-select = clipboard
    window-padding-balance = true
    window-save-state = always
    macos-titlebar-style = transparent
    background-opacity = 0.8
    background-blur = 90
    shell-integration = fish
  '';
}
