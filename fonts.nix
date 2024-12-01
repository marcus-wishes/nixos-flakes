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
    nerd-fonts.hack
    nerd-fonts.iosevka
    nerd-fonts.droid-sans-mono
    nerd-fonts.geist-mono
    nerd-fonts.open-dyslexic
  ];
}
