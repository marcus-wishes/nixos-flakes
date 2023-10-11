{ pkgs, config, ...}:
let 
  my-python-packages = ps: with ps; [
    pandas
    pygments
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
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" "keys" config.users.groups.keys.name ];
    packages = with pkgs; [
      neovim
      lm_sensors
      firefox
      brave
      vscode
      vlc
      keepassxc
      github-desktop
      signal-desktop
      jetbrains.idea-ultimate
      gradle
      kotlin
      docker-compose
      nodejs
      chezmoi
      (python3.withPackages my-python-packages)
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
      pinta
      #gnome.gnome-tweaks
      #gnome.gnome-shell-extensions
      #gnomeExtensions.timepp
      tex
      tikzit
      #go
      tortoisehg
      libsecret
      popcorntime

      google-chrome
      microsoft-edge-beta
      vivaldi
      bun

      #additional kde stuff
      libsForQt5.kcalc

      sqlitebrowser
    ];
  };

  environment.sessionVariables = rec{
    GOROOT = "$HOME/go/go";
    PATH = [
      "$HOME/go/go/bin"
      "$HOME/.npm-global/bin"
    ];
    FORGE_EMAIL = "$(cat /run/secrets/forge_email)";
    FORGE_API_TOKEN = "$(cat /run/secrets/forge_api_token)";
  };
}
