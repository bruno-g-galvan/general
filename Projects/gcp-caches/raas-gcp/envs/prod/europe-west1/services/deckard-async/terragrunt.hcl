terraform {
  source = run_cmd(
    "${get_parent_terragrunt_dir()}/.terraform-tooling/bin/module-ref",
    "redis-instance"
  )
}

include {
  path = find_in_parent_folders()
}

inputs = {
  cache_name = "deckard-async"
  memory_size = 1
  labels = {
    owner = "raas"
    service = "raas_redis_instance"
    tenantservice = "deckard"
    ticket = "raas-2371"
  }
}