{
    config,
    lib,
    ...
}: {
    imports = [
        ./desktop
        ./shell
        ./terminal
        ./editors
        ./browser
    ];

    options.nesw.enable = lib.mkEnableOption "nesw";
}
