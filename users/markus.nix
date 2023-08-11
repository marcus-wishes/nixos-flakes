{ pkgs, ...}:
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
    extraGroups = [ "networkmanager" "wheel" "audio" "docker" ];
    packages = with pkgs; [
      neovim
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
      postman
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
      go
      tortoisehg

      google-chrome
      microsoft-edge-beta

      #additional kde stuff
      libsForQt5.kcalc

      sqlitebrowser
    ];
  };
}
