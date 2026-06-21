{
    config,
    lib,
    ...
}: let
    zoxide = config.programs.zoxide;
    zoxideOptions = lib.concatStringsSep " " zoxide.options;
in {
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

        shellInitLast = lib.mkIf zoxide.enable ''
            ${lib.getExe zoxide.package} init fish ${zoxideOptions} | source
        '';
    };

    xdg.configFile."fish/functions" = {
        source = ./functions;
        recursive = true;
    };
}
