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
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  # enabled Flakes and the new command line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Enable networking
  networking.networkmanager.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  #boot.kernelPackages = pkgs.linuxPackages_zen; # use latest zen kernel
  
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # cachy OS kernel with improved shedulers
  # https://www.nyx.chaotic.cx/
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  
  
  boot.supportedFilesystems = [ "ntfs" ];
  # unfortunately this doesnt help against the ACPI errors:
  boot.kernelParams = [
    #''acpi_osi=! acpi_osi="Windows 2015"''
    ''acpi_osi=!" "acpi_osi="Windows 2015"''
    #''acpi_osi="!Windows 2022"''
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "NVreg_EnableGpuFirmware=0"
  ];


  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
    LC_ALL = "de_AT.UTF-8";
    LANGUAGE = "de_AT:de:en_US:en";
  };
  
  environment.variables = {
    EDITOR = "vim";
  };

  /* run nix garbage collection */
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  /* enable nix optimise */
  nix.settings.auto-optimise-store = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb.layout = "at";
    xkb.variant = "";
    /*libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
    };*/
  };

  services.libinput = {
    enable = true;
    touchpad.disableWhileTyping = true;
  };

 
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  #sound.enable = true;
  #sound.mediaKeys = {
  #  enable = true;
  #  volumeStep = "5%";
  #};
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.graphics.extraPackages = with pkgs; [ nvidia-vaapi-driver intel-ocl intel-media-driver intel-compute-runtime libva libdrm libvdpau mesa ];

  # gnome keyring to be used for the network manager applet in i3
  services.gnome.gnome-keyring.enable = true;
  #services.gnome.seahorse.enable = true;

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
    unzip
    bat
    tmux
    killall
    fd
    fzf
    rxvt-unicode
    #nix-index
    gnumake
    age # age encryption
    sops # secrets
    vdpauinfo
    libva-utils
    #power-profiles-daemon
  ];

  programs.git = {
    enable = true;
  };

  programs.nix-ld = {
    enable = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };  

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # enabled docker socket
      dockerSocket.enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };

  
    

    #docker = {
    #  enable = true;
    #  storageDriver = "btrfs";
      #rootless = {
      #  enable = true;
      #setSocketVariable = true;
      #};
   # };
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

  programs.yazi = {
    enable = true;
  };

}
