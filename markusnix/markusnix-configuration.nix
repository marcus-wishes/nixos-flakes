# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, kernel, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # enable thermal management
  services.thermald.enable = true;
  # laptop power management
  # gnome and kde have power-profile-daemon enabled
  #services.tlp = {
  #  enable = true;
  #};

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "markusnix"; # Define your hostname.
  networking.extraHosts = "127.0.0.1 jira\n127.0.0.1 confluence";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #yubikey und gpg
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };
  programs.ssh = {
    startAgent = true;
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];
  
  # smarcard service, required for pgp
  services.pcscd.enable = true;


  #boot.blacklistedKernelModules = [ "nvidia" "nvidia_drm" "nvidia_modeset" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    #open =  false;
    open = lib.mkDefault true;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # package overwrite because of instability of the 550 driver - https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
    #package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #  version = "535.154.05";
    #  sha256_64bit = "sha256-fpUGXKprgt6SYRDxSCemGXLrEsIA6GOinp+0eGbqqJg=";
    #  sha256_aarch64 = "sha256-G0/GiObf/BZMkzzET8HQjdIcvCSqB1uhsinro2HLK9k=";
    #  openSha256 = "sha256-wvRdHguGLxS0mR06P5Qi++pDJBCF8pJ8hr4T8O6TJIo=";
    #  settingsSha256 = "sha256-9wqoDEWY4I7weWW05F4igj1Gj9wjHsREFMztfEmqm10=";
    #  persistencedSha256 = "sha256-d0Q3Lk80JqkS1B54Mahu2yY/WocOqFFbZVBh+ToGhaE=";
    #};

    nvidiaPersistenced = lib.mkDefault true;
    modesetting.enable = lib.mkDefault true;
    powerManagement.finegrained = false;
    powerManagement.enable = lib.mkDefault true;
    dynamicBoost.enable = lib.mkDefault true;
    prime = {
      #offload.enable = true; # use only intel gpu by default and use nvidia only when needed using nvidia-offload
      sync.enable = lib.mkDefault true; # always only run on nvidia
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # booting with external display:
  # specialisation = {
  #  external-display.configuration = {
  #    system.nixos.tags = [ "external-display" ];
  #    hardware.nvidia.prime.offload.enable = lib.mkForce false;
  #    hardware.nvidia.powerManagement.enable = lib.mkForce false;
  #  };
  #};


  #specialisation = {
  #  nouveau.configuration = {
  #    system.nixos.tags = [ "nouveau" ];
  #    boot.blacklistedKernelModules = [ "nvidia" "nvidia_drm" "nvidia_modeset" ];
  #  };
  #};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  # backlight handling
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      # "Mute" media key
      { keys = [ 113 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/runuser -l markus -c 'amixer -q set Master toggle'"; }
      # "Lower Volume" media key
      { keys = [ 114 ]; events = [ "key" "rep" ]; command = "/run/current-system/sw/bin/runuser -l markus -c 'amixer -q set Master 5%- unmute'"; }
      # "Raise Volume" media key
      { keys = [ 115 ]; events = [ "key" "rep" ]; command = "${pkgs.alsaUtils}/bin/amixer -q set Master ${config.sound.mediaKeys.volumeStep}+ unmute"; }

      # backlight up
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 5"; }
      # backlight down
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 5"; }

    ];
  };
}
