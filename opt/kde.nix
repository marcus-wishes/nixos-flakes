{ pkgs, services, programs, ...}:
{
  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # GTK Themes not applied in Wayland fix:
  programs.dconf.enable = true;
}
