{ pkgs, ...}:
{
  # i3
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      rofi
      polybar
      dunst
      pavucontrol
      i3status #default i3 status bar
      i3lock #default i3 screen locker
      networkmanagerapplet
      feh
      xfce.thunar
      xfce.thunar-volman
      xfce.thunar-archive-plugin
      xfce.thunar-media-tags-plugin
    ];
  };

  # gnome keyring to be used for the network manager applet in i3
  services.gnome.gnome-keyring.enable = true;
}