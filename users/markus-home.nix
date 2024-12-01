{ pkgs, ...}:
{
  home.username = "markus";
  home.stateVersion = "22.11";
  home.homeDirectory = "/home/markus";
  home.packages = with pkgs; [
    # fish plugins
    fishPlugins.grc
    fishPlugins.fzf-fish # fuzzy finder
    fishPlugins.sponge # history without typos
    starship # shell prompt
    grc # colorized command output
  ];

  # add ssh keys to the agent
  services.ssh-agent.enable = true;

  programs.fish = {
    enable = true;
    plugins = [
      # Enable a plugin (here grc for colorized command output) from nixpkgs
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "fzf"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }
    ];

    shellAliases = {
      # Add a shell alias
      ll = "ls -lh";
      copgit = "github-copilot-cli git-assist";
      cop = "github-copilot-cli what-the-shell";
      nvim2 = "nix run ~/nixvim";
    };

    # Set the prompt to starship
    interactiveShellInit = ''
      starship init fish | source
      zoxide init fish | source
    '';
  };
  
  home.file.".npmrc".text = ''
    prefix=~/.npm-global
  '';

  home.file.".bashrc".text = ''
    eval "$(direnv hook bash)"
  '';

  home.file.".Xresources".text = ''
    !! Colorscheme

    *.background: #282828
    !*.foreground: #ebdbb2
    *.background-alt: #373B41
    *.primary: #F0C674
    *.secondary: #8ABEB7
    *.alert: #A54242
    *.disabled: #707880


    ! special
    *.cursorColor: #93a1a1
    *.foreground: #c5c8c6
    !*.foreground: #93a1a1
    !*.background: #141c21
    !*.cursorColor: #afbfbf

    ! black
    *.color0: #263640
    *.color8: #4a697d

    ! red
    *.color1: #d12f2c
    *.color9: #fa3935

    ! green
    *.color2: #819400
    *.color10: #a4bd00

    ! yellow
    *.color3: #b08500
    *.color11: #d9a400

    ! blue
    *.color4: #2587cc
    *.color12: #2ca2f5

    ! magenta
    *.color5: #696ebf
    *.color13: #8086e8

    ! cyan
    *.color6: #289c93
    *.color14: #33c5ba

    ! white
    *.color7: #bfbaac
    *.color15: #fdf6e3

    !! URxvt Appearance
    URxvt*font:                 xft:JetBrains Mono:pixelsize=12, xft:DejaVu Sans:pixelsize=8, xft:Symbola
    URxvt*boldFont:             xft:JetBrains Mono:pixelsize=12, xft:DejaVu Sans:pixelsize=8, xft:Symbola
    URxvt.italicFont:           xft:JetBrains Mono:pixelsize=12, xft:DejaVu Sans:pixelsize=8, xft:Symbola
    URxvt.boldItalicfont:       xft:JetBrains Mono:pixelsize=12, xft:DejaVu Sans:pixelsize=8, xft:Symbola
    URxvt.letterSpace: 0
    URxvt.lineSpace: 0
    URxvt.geometry: 92x24
    URxvt.internalBorder: 8
    URxvt.cursorBlink: true
    URxvt.cursorUnderline: false
    URxvt.saveline: 2048
    URxvt.scrollBar: false
    URxvt.scrollBar_right: false
    URxvt.urgentOnBell: true
    URxvt.depth: 32
    URxvt.iso14755: false
    URxvt.transparent: true
    URxvt.shading: 20

    URxvt.urlLauncher: brave 
    URxvt.underlineURLs: true
    URxvt.urlButton: 1
  '';
}
