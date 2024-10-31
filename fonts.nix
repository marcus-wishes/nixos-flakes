{ pkgs, ...}:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    jetbrains-mono
    siji
    (nerdfonts.override { fonts = [ "Iosevka" "DroidSansMono" "Hack" ]; })
  ];
}
