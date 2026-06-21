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
            "--style=full"
            "--border"
            "--padding=1,2"
            "--color=bg:#09090b,fg:#fafafa,hl:#e4e4e7,pointer:#e4e4e7,marker:#71717a"
            "--color=border:#52525b,label:#a1a1aa"
            "--color=preview-bg:#18181b,preview-border:#3f3f46,preview-label:#e4e4e7"
            "--color=list-border:#52525b,list-label:#a1a1aa"
            "--color=input-border:#71717a,input-label:#f4f4f5"
            "--color=header-border:#3f3f46,header-label:#d4d4d8"
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
