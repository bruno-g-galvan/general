dns_managed_zone = "dz-stable-sharedvpc01-gds-stable"
db_cname = "goods-inventory-service"
cnames = [
{
db_access_type = "rw"
aws_backend = "pg-core-us-533-stg.ccoxqscq6x7v.us-west-1.rds.amazonaws.com."
gcp_backend = "pg-core-emea-581-stg-rw.europe-west1.gds.stable.gcp.groupondev.com."
aws_weight = 1
gcp_weight = 0
},
{
db_access_type = "ro"
aws_backend = "pg-core-us-533-stg-1.ccoxqscq6x7v.us-west-1.rds.amazonaws.com."
gcp_backend = "pg-core-emea-581-stg-ro.europe-west1.gds.stable.gcp.groupondev.com."
aws_weight = 1
gcp_weight = 0
}
]