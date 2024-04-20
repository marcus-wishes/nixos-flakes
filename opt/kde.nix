{ pkgs, services, programs, ...}:
{
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # GTK Themes not applied in Wayland fix:
  programs.dconf.enable = true;
}
