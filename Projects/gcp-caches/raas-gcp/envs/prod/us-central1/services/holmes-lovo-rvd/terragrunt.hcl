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
  cache_name = "holmes-lovo-rvd"
  memory_size = 35
  labels = {
    service  = "watson-api"
    ticket = "raas-1152"
  }
}