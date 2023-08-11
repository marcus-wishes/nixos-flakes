# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  nix-alien-pkgs = import (
    builtins.fetchTarball "https://github.com/thiagokokada/nix-alien/tarball/master"
  ) { };
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
  /*tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full
      latexmk;
  });
  my-python-packages = ps: with ps; [
    pandas
    pygments
  ];*/
in
{
  imports =
    [ # Include the results of the hardware scan.
      #./hardware-configuration.nix
      ./hardware-configuration.nix
    ];

  # enabled Flakes and the new command line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_zen; # use latest zen kernel
  boot.supportedFilesystems = [ "ntfs" ];
  # unfortunately this doesnt help against the ACPI errors:
  #boot.kernelParams = [
  #  ''acpi_osi="!Windows 2022"''
  #];

  # Todo remove again if possibe, but i dont know what depends on it
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1v"
  ];

  # enable thermal management
  services.thermald.enable = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "markusnix"; # Define your hostname.
  networking.extraHosts = "127.0.0.1 jira\n127.0.0.1 confluence";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };
  
  environment.variables = {
    EDITOR = "vim";
    #NODE_PATH = "/etc/profiles/per-user/markus/bin/node";
  };
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  #yubikey und gpg
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.udev.packages = [ pkgs.yubikey-personalization ];
  
  # smarcard service, required for pgp
  services.pcscd.enable = true;

  # gnome keyring to be used for the network manager applet in i3
  services.gnome.gnome-keyring.enable = true;
  #services.gnome.seahorse.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "at";
    xkbVariant = "";

    # Enable touchpad support
    libinput.enable = true;
    #libinput.touchpad = {
	#tapping = true;	
    #};
  };
  
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    #sync.enable = true; # always only run on nvidia
    offload.enable = true;
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # booting with external display:
  specialisation = {
    external-display.configuration = {
      system.nixos.tags = [ "external-display" ];
      hardware.nvidia.prime.offload.enable = lib.mkForce false;
      hardware.nvidia.powerManagement.enable = lib.mkForce false;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    lshw
    wget
    curl
    gitFull
    nvidia-offload
    htop
    wayland
    xdg-utils # for opening default programs when clicking something
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    clinfo
    glxinfo
    libsForQt5.kio-gdrive # google drive integration
    fish
    unzip
    bat
    tmux
    killall
    fd
    rxvt-unicode
    nix-index
    gnumake
    popcorntime

    # minecraft
    #prismlauncher
    #nix-alien-pkgs.nix-alien
  ];

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };
  
  programs.java = {
    enable = true;
    package = pkgs.jdk8;
  };

  programs.git = {
    enable = true;
  };

  programs.nix-ld = {
    enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services.gvfs.enable = true; # for mtp for android phones

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
