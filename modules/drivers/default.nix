/*
  GPU driver stack — Mesa/Vulkan/VA-API base + vendor-specific blocks.

  Enable exactly one of nesw.drivers.{amdgpu,intel,nvidia}.enable.
  Exposes: nesw.drivers.amdgpu|intel|nvidia.enable
*/
{ config, lib, pkgs, ... }:
with lib;
let
  driversEnabled = with config.nesw.drivers; [
    amdgpu.enable
    intel.enable
    nvidia.enable
  ];
in
{
  options.nesw.drivers = {
    amdgpu.enable = mkEnableOption "AMD GPU (amdgpu + RADV)";
    intel.enable = mkEnableOption "Intel iGPU / Arc (i915 / xe)";
    nvidia.enable = mkEnableOption "NVIDIA proprietary driver";
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = count (x: x) driversEnabled <= 1;
          message = "nesw.drivers: enable at most one of amdgpu, intel, or nvidia.";
        }
      ];
    }

    # base: Mesa GL/Vulkan/VA-API, common to every vendor
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    }

    # AMD
    (mkIf config.nesw.drivers.amdgpu.enable {
      boot.initrd.kernelModules = [ "amdgpu" ];
      services.xserver.videoDrivers = [ "amdgpu" ];
    })

    # Intel
    (mkIf config.nesw.drivers.intel.enable {
      boot.initrd.kernelModules = [ "i915" ];
      services.xserver.videoDrivers = [ "modesetting" ];
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
        intel-compute-runtime
      ];
    })

    # NVIDIA
    (mkIf config.nesw.drivers.nvidia.enable {
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = false;
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      hardware.graphics.extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      environment.sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    })
  ];
}
