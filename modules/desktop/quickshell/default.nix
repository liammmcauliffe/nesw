# qs -c nesw
{
    config,
    lib,
    pkgs,
    quickshell,
    ...
}: let
    cfg = config.programs.quickshell.nesw;
    greeterCfg = config.services.quickshell.greeter;
    qsPkg = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
    options.programs.quickshell.nesw.enable =
        lib.mkEnableOption "NESW Quickshell";

    options.services.quickshell.greeter.enable =
        lib.mkEnableOption "NESW Quickshell greeter config at /etc/xdg/quickshell/greeter";

    config = lib.mkMerge [
        (lib.mkIf cfg.enable {
            home.packages = [qsPkg];

            xdg.configFile."quickshell/nesw" = {
                source = ./config;
                recursive = true;
            };
        })
        (lib.mkIf greeterCfg.enable {
            environment.etc."xdg/quickshell/greeter".source = ./config/greeter;
        })
    ];
}
