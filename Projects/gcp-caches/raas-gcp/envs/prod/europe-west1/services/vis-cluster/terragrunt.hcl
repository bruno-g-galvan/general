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
  cache_name = "vis"
  shard_count = 7
  node_type = "REDIS_SHARED_CORE_NANO"
  replica_count = 0
  labels = {
    owner = "raas"
    service = "raas_redis_cluster"
    tenantservice = "voucher-inventory-jtier"
    ticket = "raas-1129"
  }
}