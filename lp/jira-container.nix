
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

      networking.firewall.enable = false;
      networking.firewall.allowedTCPPorts = [ 8080 ];

      users.groups.jira = {};
      users.users.jira = {
        isSystemUser = true;
        #home = "/var/lib/jira";
        createHome = true;
        group = "jira";
      };

      systemd.user.services.jiradirs = {
        description = "make sure the necessary directories exist";
        script = ''
          mkdir -p /home/jira
          chown -R jira:jira /home/jira
          mkdir -p /var/tmp/jira
          chown -R jira:jira /var/tmp/jira
          mkdir -p /home/jira/logs
          chown -R jira:jira /home/jira/logs
          mkdir -p /home/jira/work
          chown -R jira:jira /home/jira/work
        '';
        wantedBy = [ "multi-user.target" ]; # starts after login
      };

      environment.sessionVariables = rec{
        #JIRA_HOME = "/var/lib/jira";
        JIRA_HOME = "/home/jira";
        JIRA_USER = "jira";
        CATALINA_BASE = "/home/jira";
        #CATALINA_HOME = "/home/jira";
        CATALINA_TMPDIR = "/var/tmp/jira";
      };

      services.jira = {
        #https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/atlassian/jira.nix
        enable = true;
        listenPort = 8080;
        jrePackage = pkgs.jdk11;
        user = "jira";
        group = "jira";
        #home = "/var/lib/jira";
        home = "/home/jira";
        #jiraVersion = "8.5.1";
      };
      

      system.stateVersion = "22.11";
    };


  };
}