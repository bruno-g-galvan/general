  db_name = "arbitration_prod"
  db_instance_name = "pg-arbitration-service-prod"
  db_type = "postgres"
  db_version = "POSTGRES_15"
  db_tier = "db-custom-16-92160"
  disk_size = 1000
  max_connections = 5669
  log_connections = "on"
  pg_cron = "on"
  replica_count = 0
  max_worker_processes = 16
  max_logical_replication_workers = 12
  max_wal_senders = 12
  max_replication_slots = 12