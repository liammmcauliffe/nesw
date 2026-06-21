{pkgs, ...}: {
    programs.eza = {
        enable = true;
        enableFishIntegration = true;
        icons = "auto";
        git = true;
        extraOptions = [
            "--group-directories-first"
            "--header"
            "--hyperlink"
            "--time-style=relative"
        ];
    };

    programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = ["--cmd" "cd"];
    };

    programs.bat = {
        enable = true;
        config = {
            theme = "TwoDark";
            style = "numbers,changes,header";
            paging = "auto";
        };
    };

    programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        defaultOptions = [
            "--height 40%"
            "--layout=reverse"
            "--info=inline"
            "--preview 'bat --color=always {}'"
        ];
    };

    home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
    };

    home.packages = with pkgs; [
        ripgrep
        fd
        jq
    ];
}
