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
            set -ax FZF_DEFAULT_OPTS "--border-label=' nesw ' --input-label=' Search ' --header-label=' Info '"
        '';
    };

    xdg.configFile."fish/functions" = {
        source = ./functions;
        recursive = true;
    };
}
