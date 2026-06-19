{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ghostty
  ];

  xdg.configFile."ghostty/config".text = ''
    font-family = "Monaspace Neon NF"
    font-size = 14

    # window - Hyprland handles
    window-decoration = false
    gtk-tabs = false
    window-vsync = true
    window-padding-x = 10
    window-padding-y = 10
    window-padding-balance = true
    window-save-state = always

    # appearance
    theme = "Vague"
    window-colorspace = display-p3
    background-opacity = 0.8
    background-blur = 90
    cursor-style = block
    adjust-cell-height = 35%

    # input
    copy-on-select = clipboard
    mouse-hide-while-typing = true
    mouse-scroll-multiplier = 2

    # shell
    shell-integration = fish
  '';
}
