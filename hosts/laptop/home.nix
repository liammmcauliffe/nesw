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

    programs.quickshell.nesw.enable = true;
}
