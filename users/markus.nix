{ pkgs, config, mkOption, types, literalExpression, ...}:
let 
  my-python-packages = ps: with ps; [
    pandas
    pygments
    #meson-python
  ];
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-full
      latexmk;
  });
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.markus = {
    isNormalUser = true;
    description = "Markus";
    createHome = true;
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "keys" "video" "render" "podman" config.users.groups.keys.name ];
    packages = with pkgs; [
      neovim
      lm_sensors
      firefox
      brave
      vscode
      vlc
      keepassxc
      github-desktop
      #signal-desktop
      jetbrains.idea-ultimate
      gradle
      kotlin
      #docker-compose
      podman-compose
      podman-desktop
      #distrobox
      nodejs
      #chezmoi
      (python310.withPackages my-python-packages)
      slack
      pinentry
      yubico-pam
      appimage-run
      kate
      gcc
      git-lfs
      nodePackages.npm
      pass
      pinentry-curses
      entr
      inkscape
      imagemagick
      pinta
      #gnome.gnome-tweaks
      #gnome.gnome-shell-extensions
      #gnomeExtensions.timepp
      tex
      tikzit
      #go
      #tortoisehg
      libsecret
      graphviz
      maven
      mercurial
      #meson #python build system

      popcorntime
      transmission_4-qt

      google-chrome
      microsoft-edge
      vivaldi
      bun
      #freetube
      steam-run
      mediawriter
      floorp

      #additional kde stuff
      kdePackages.kcalc

      zoxide # a better cd
      github-copilot-cli

      nh # yet another nix cli helper tool

      #sqlitebrowser
      #python dependency management
      #poetry

      orca # screen reader
    ];
  };
  
  programs.direnv.enable = true;
  
  environment.sessionVariables = rec{
    GOROOT = "$HOME/go/go";
    PATH = [
      "$HOME/go/go/bin"
      "$HOME/.npm-global/bin"
    ];
    #NODE_PATH = "/etc/profiles/per-user/markus/bin/node";
    FORGE_EMAIL = "$(cat /run/secrets/forge_email)";
    FORGE_API_TOKEN = "$(cat /run/secrets/forge_api_token)";

    # wayland stuff:
    #LIBVA_DRIVER_NAME="nvidia";
    #XDG_SESSION_TYPE = "wayland";
    # with nvidia-drm kde doesnt start in wayland   
    #GBM_BACKEND = "nvidia-drm";
    #GBM_BACKEND = "nvidia";
    #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # make vscode + elecon apps use wayland. else typing is slow
    #NIXOS_OZONE_WL = "1";
    #NVD_BACKEND = "direct";

  };
}
