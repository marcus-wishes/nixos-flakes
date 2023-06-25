{ pkgs, ...}:
let 
  my-python-packages = ps: with ps; [
    pandas
    pygments
  ];
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.markusNew = {
    isNormalUser = true;
    description = "Markus 2";
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
      #nodejs-slim-14_x
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
      gnome.gnome-tweaks
    ];
  };
}