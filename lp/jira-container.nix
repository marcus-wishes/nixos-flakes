
{nixpkgs, ...}:
{
  # Export the Jira container
  containers.jira = {
    ephemeral = true;
    autoStart = false;
    config = { config, pkgs, users, ... }: {
      nixpkgs.config.allowUnfree = true;

      programs.java = {
        enable = true;
        package = pkgs.jdk11;
        #package = pkgs.jdk8;
      };

      networking.firewall.allowedTCPPorts = [ 8080 ];

      users.groups.jira = {};
      users.users.jira = {
        isSystemUser = true;
        #home = "/var/lib/jira";
        createHome = true;
        group = "jira";
      };

      environment.sessionVariables = rec{
        #JIRA_HOME = "/var/lib/jira";
        JIRA_HOME = "/home/jira";
        JIRA_USER = "jira";
        CATALINA_BASE = "/home/jira";
        #CATALINA_HOME = "/home/jira";
        CATALINA_TMPDIR = "/var/tmp/jira";
      };

      # requires postgres
      services.postgresql = {
        enable = false;
        enableTCPIP = true;
        settings.port = 5432;
        authentication = pkgs.lib.mkOverride 10 ''
          #type database  DBuser  auth-method optional_ident_map
          local sameuser  all     peer        map=superuser_map
          # ipv4
          host  all      all     127.0.0.1/32   trust
          # ipv6
          host all       all     ::1/128        trust
        '';
      };
      
      
      services.jira = {
        #https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/atlassian/jira.nix
        enable = false;
        listenPort = 8080;
        jrePackage = pkgs.jdk11;
        user = "jira";
        group = "jira";
        #home = "/var/lib/jira";
        home = "/home/jira";
      };
      

      system.stateVersion = "22.11";
    };


  };
}