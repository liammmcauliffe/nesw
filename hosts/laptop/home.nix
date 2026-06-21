{...}: {
    imports =
        [
            ../../modules/nesw.nix
        ]
        ++ (
            if builtins.pathExists ./shared.nix
            then [./shared.nix]
            else []
        )
        ++ (
            if builtins.pathExists ./home.local.nix
            then [./home.local.nix]
            else []
        );

    nesw.enable = true;
    programs.quickshell.nesw.enable = true;
}
