terraform {
source = run_cmd(
"${get_parent_terragrunt_dir()}/.terraform-tooling/bin/module-ref",
"redis-cname"
)
}

include {
path = find_in_parent_folders()
}

inputs = {
cache_cname = "dlsvc-shield-queue-memorystore.us-central1.caches.stable.gcp.groupondev.com."
cnames = [
{
aws_backend = "dlsvc-shield-queue--redis.staging.stable.us-west-1.aws.groupondev.com."
gcp_backend = "dlsvc-shield-queue.us-central1.caches.stable.gcp.groupondev.com."
aws_weight = 1
gcp_weight = 0
}
]
}