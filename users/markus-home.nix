{ pkgs, ...}:
{
  home.username = "markus";
  home.stateVersion = "22.11";
  home.homeDirectory = "/home/markus";
  home.packages = with pkgs; [
    google-chrome
  ];
}