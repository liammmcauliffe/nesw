{pkgs, ...}: {
    home.packages = with pkgs; [
        ghostty
    ];

    xdg.configFile."ghostty/themes/nesw-zinc".source = ./themes/nesw-zinc;

    xdg.configFile."ghostty/config".text = ''
        font-family = "Monaspace Neon NF"
        font-size = 20

        # window
        window-decoration = none
        window-vsync = true
        window-padding-x = 10
        window-padding-y = 10
        window-padding-balance = true
        window-save-state = always

        # appearance
        theme = nesw-zinc
        background-opacity = 0.8
        background-blur = 90
        adjust-cell-height = 0%

        # input
        copy-on-select = clipboard
        mouse-hide-while-typing = true
        mouse-scroll-multiplier = 1

        # shell
        shell-integration = fish
    '';
}
