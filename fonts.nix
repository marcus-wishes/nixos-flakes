{ pkgs, ...}:
{
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    jetbrains-mono
    siji
    (nerdfonts.override { fonts = [ "Iosevka" "DroidSansMono" "Hack" ]; })
  ];
}