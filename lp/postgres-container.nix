{nixpkgs, config, ...}:
{
  containers.postgres = {
    ephemeral = true;
    autoStart = false;
    config = {config, pkgs, users, services, ...}:{

      networking.firewall.enable = false;
      networking.firewall.allowedTCPPorts = [ 5432 ];
      
      # use postgres user
      users.groups.postgres = {};
      users.users.postgres = {
        isSystemUser = true;
        #home = "/var/lib/postgres";
        createHome = false;
        group = "postgres";
      };

      # postgres service
      services.postgresql = {
        enable = true;
        enableTCPIP = true;
        #ensureDatabases = [ "postgres" ];
        #ensureUsers = [
        #  {
        #    name = "postgres";
        #  }
        #];

        #  package = nixpkgs.postgresql;
        settings = {
          port = 5432;
          listen_addresses = "*";
          #max_connections = 100;
          #username = "postgres";
          #password = "postgres";
        };

        authentication = pkgs.lib.mkOverride 10 ''
          #type database  DBuser  auth-method optional_ident_map
          # ipv4
          host  all      all     0.0.0.0/0      trust
          local all      all                    trust
          # ipv6
          host all       all     ::1/128        trust
        '';
      };

      system.stateVersion = "22.11";
    };
  };
}