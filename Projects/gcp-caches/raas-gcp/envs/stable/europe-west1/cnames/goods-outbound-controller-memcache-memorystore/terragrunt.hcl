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
cache_cname = "goods-outbound-controller-memcache-memorystore.europe-west1.caches.stable.gcp.groupondev.com."
cnames = [
{
aws_backend = "goods-outbound-controller--cache.staging.service.stable.us-west-2.aws.groupondev.com."
gcp_backend = "goods-outbound-controller-memcache.europe-west1.caches.stable.gcp.groupondev.com."
aws_weight = 0
gcp_weight = 1
}
]
}