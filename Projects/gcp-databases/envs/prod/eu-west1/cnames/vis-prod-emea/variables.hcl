db_cname = "vis-prod-emea"
cnames = [
{
db_access_type = "rw"
aws_backend = "vis-prod-replica.cluster-ro-cqgqresxrenm.eu-west-1.rds.amazonaws.com."
gcp_backend = "vis-prod-emea-1.gds.prod.gcp.groupondev.com."
aws_weight = 1
gcp_weight = 0
},
{
db_access_type = "ro"
aws_backend = "vis-prod-replica.cluster-ro-cqgqresxrenm.eu-west-1.rds.amazonaws.com."
gcp_backend = "vis-prod-emea-1.gds.prod.gcp.groupondev.com."
aws_weight = 1
gcp_weight = 0
}
]