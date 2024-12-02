{
  description = "Markus NixOS Flake Config";

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # and `outputs` function will return all the build results of the flake.
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Official NixOS package source, using nixos-unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nyx chaotic for CachyOS kernel
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # `outputs` are all the build result of the flake.
  # A flake can have many use cases and different types of outputs.
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, This special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = { self, nixpkgs, home-manager, sops-nix, chaotic, ... }@inputs: {

    # `nixosConfigurations` is a special attribute set, which is used to define NixOS configurations.
    nixosConfigurations = {
      # By default, NixOS will try to refer the nixosConfiguration with its hostname.
      # so the system named `nixos-test` will use this configuration.
      # However, the configuration name can also be specified using `sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>`.
      # The `nixpkgs.lib.nixosSystem` function is used to build this configuration, the following attribute set is its parameter.
      # Run `sudo nixos-rebuild switch --flake .#nixos-test` in the flake's directory to deploy this configuration on any NixOS system
      markusnix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        # The Nix module system can modularize configuration, improving the maintainability of configuration.
        #
        # Each parameter in the `modules` is a Nix Module, and there is a partial introduction to it in the nixpkgs manual:
        #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
        # It is said to be partial because the documentation is not complete, only some simple introductions
        #    (such is the current state of Nix documentation...)
        # A Nix Module can be an attribute set, or a function that returns an attribute set.
        # If a Module is a function, this function can only have the following parameters:
        #
        #  lib:     the nixpkgs function library, which provides many useful functions for operating Nix expressions
        #            https://nixos.org/manual/nixpkgs/stable/#id-1.4
        #  config:  all config options of the current flake
        #  options: all options defined in all NixOS Modules in the current flake
        #  pkgs:   a collection of all packages defined in nixpkgs.
        #           you can assume its default value is `nixpkgs.legacyPackages."${system}"` for now.
        #           can be customed by `nixpkgs.pkgs` option
        #  modulesPath: the default path of nixpkgs's builtin modules folder,
        #               used to import some extra modules from nixpkgs.
        #               this parameter is rarely used, you can ignore it for now.
        #
        # Only these parameters can be passed by default.
        # If you need to pass other parameters, you must use `specialArgs` by uncomment the following line
        # with inputs we can use all the parameters of the flake as arguments of the module
        specialArgs = inputs;
        modules = [
          # Import the configuration.nix we used before, so that the old configuration file can still take effect.
          # Note: /etc/nixos/configuration.nix itself is also a Nix Module, so you can import it directly here
          ./basics.nix
          ./fonts.nix
          
          ./opt/kde.nix

          # Import the i3 configuration
          #./opt/i3.nix
          
          # create the default user + programs
          ./users/markus.nix

          #work stuff
          ./lp/work.nix
          #./lp/postgres-container.nix
          #./lp/jira-container.nix

          ./nix-ld.nix

          # add the sops-nix module to make secrets available in /run/secrets
          sops-nix.nixosModules.sops
          {
            sops.defaultSopsFile = "/home/markus/nix-flakes/secrets/secrets.yaml"; # the default file to look for secrets
            sops.age.keyFile = "/home/markus/.config/sops/age/keys.txt"; # age key pair
            sops.validateSopsFiles = false; # else it complains that the secret files are not in the nix store
            sops.secrets.forge_api_token = {
              owner = "markus";
              mode = "0400";
            };
             sops.secrets.forge_email = {
              owner = "markus";
              mode = "0400";
            };
          }

          # home-manager, used for managing user configuration
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.markus = {
              imports = [
                ./users/markus-home.nix
              ];
            };
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }

          # specialized configuration for my laptop
          ./markusnix/markusnix-configuration.nix

          # chaotic default modules
          chaotic.nixosModules.default
        ];
      };
    };
  };
}
