{
  description = "A flake with a declarative Jira container";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs :
    let

      # Declare the system
      system = "x86_64-linux";
      # Use a system-specific version of Nixpkgs
      pkgs = import nixpkgs { 
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

    in {
      
      # Export the Jira container
      nixosConfigurations.container.jira = {
        ephemeral = true;
        autoStart = false;
        config = { config, pgks, ... }: {
          services.jira.enable = true;
          #services.jira.database = {
          #  type = "postgresql";
          #  password = "password";
          #};
        };
      };
    };
}