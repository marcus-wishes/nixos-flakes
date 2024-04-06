{ pkgs, ...}:
{
  programs.java = {
    enable = true;
    package = pkgs.jdk11;
    #package = pkgs.jdk8;
  };
}
