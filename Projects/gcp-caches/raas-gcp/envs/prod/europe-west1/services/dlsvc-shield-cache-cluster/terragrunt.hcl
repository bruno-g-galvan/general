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
  cache_name = "dlsvc-shield-cache"
  shard_count = 8
  node_type = "REDIS_STANDARD_SMALL"
  replica_count = 0
  labels = {
    owner = "raas"
    service = "raas_redis_cluster"
    tenantservice = "shield"
    ticket = "raas-1117"
  }
}