terraform {
  source = run_cmd(
    "${get_parent_terragrunt_dir()}/.terraform-tooling/bin/module-ref",
    "redis-cluster"
  )
}

include {
  path = find_in_parent_folders()
}

inputs = {
  cache_name = "badges-service-cloud"
  shard_count = 3
  node_type = "REDIS_SHARED_CORE_NANO"
  replica_count = 0
  labels = {
    owner = "raas"
    service = "raas_redis_cluster"
    tenantservice = "badges-service"
    ticket = "raas-1161"
  }
}