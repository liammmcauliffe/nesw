{
    pkgs,
    zen-browser,
    ...
}: {
    home.packages = [
        zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        # Disables the Remote Data Decoder sandbox, can help battery and cpu
        MOZ_DISABLE_RDD_SANDBOX = "1";
    };
}
