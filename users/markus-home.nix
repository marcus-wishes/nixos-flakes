{ pkgs, ...}:
{
  home.username = "markus";
  home.stateVersion = "22.11";
  home.homeDirectory = "/home/markus";
  home.packages = with pkgs; [
  ];

  # set gtk theme
  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-gtk-theme;
    };
  };
}