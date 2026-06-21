{...}: {
    programs.fish = {
        enable = true;

        shellAbbrs = {
            cat = "bat";
            lt = "eza --tree --icons";
            gs = "git status";
            gd = "git diff";
        };

        interactiveShellInit = ''
            set fish_greeting ""
        '';
    };

    xdg.configFile."fish/functions" = {
        source = ./functions;
        recursive = true;
    };
}
