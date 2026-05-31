{...}: {
  # Allow Alloy agents on all machines to push logs via the Netbird interface.
  # Using the NixOS interface-scoped option is backend-agnostic (works with
  # both iptables and nftables, unlike extraRules).
  networking.firewall.interfaces."wt0".allowedTCPPorts = [3100];

  services.loki = {
    enable = true;

    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
        grpc_listen_port = 9096;
        log_level = "warn";
      };

      # Single-binary / monolithic mode.
      # The common block wires up all component defaults so we don't need
      # to configure ingester, distributor, compactor etc. separately.
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/var/lib/loki";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      # In-process query result cache — avoids hammering storage on repeated
      # Grafana dashboard refreshes.
      query_range.results_cache.cache.embedded_cache = {
        enabled = true;
        max_size_mb = 100;
      };

      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      limits_config = {
        # Reject samples older than 7 days to prevent accidental backfills
        # from overwhelming storage.
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };

      analytics.reporting_enabled = false;
    };
  };
}
