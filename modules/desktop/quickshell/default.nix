# qs -c nesw
{
    config,
    lib,
    pkgs,
    quickshell,
    ...
}: let
    cfg = config.programs.quickshell.nesw;
    qsPkg = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
    options.programs.quickshell.nesw.enable =
        lib.mkEnableOption "NESW Quickshell";

    config = lib.mkIf cfg.enable {
        home.packages = [qsPkg];

        xdg.configFile."quickshell/nesw" = {
            source = ./config;
            recursive = true;
        };
    };
}
