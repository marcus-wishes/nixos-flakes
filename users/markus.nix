{ pkgs, home-manager, ...}:
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
  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

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
      inkscape
      pinta
      gnome.gnome-tweaks
    ];
  };

  home-manager = {
    useUserPackages = true;
    users.markus = { pkgs, ... } : {
      home.stateVersion = "22.11";
      home.homeDirectory = "/home/markus";
      home.packages = with pkgs; [
        tex
        tikzit
      ];
    };
  };
}