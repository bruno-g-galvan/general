terraform {
    source = "../../../../../../modules/rds-postgres"
}

include {
	path = find_in_parent_folders()
}

dependencies {
	paths = [
  		"../../../database/networking",
#     	"../../../database/options",
  		"../../../database/parameters/rds/11",
  		"../../../database/security",
	]
}


# If module specific variables need to be defined, these variables need to be defined in a "module-specific.tfvars" file inside the same directory

inputs = {
  instance_type       = "db.r5.xlarge"
  local_replica_cnt   = "1"
  local_subnet_group  = "sgroup-1"
  size                = "debug"
  engine_version	  = "11.19"
  multi_az			  = false
  apply_immediately = true
  port				  = 5432
  db_name			  = "tpis_prod"
  apply_immediately = true
  replicate_source_db = ""
  max_allocated_storage = 1000
  allocated_storage = 500
  cname = "tpis-prod"
  kms_id = "arn:aws:kms:us-west-1:497256801702:key/mrk-20435c510ff141608437364b96e1ca20"
  storage_encrypted  = true
  account_id  = get_aws_account_id()
  maintenance_window  = "mon:00:00-mon:03:00"
  jira_tag = "GDS-32491"
  service_tag = "daas_postgres"
  owner_tag = "gds@groupon.com"
  tenantteam_tag = "tpis-third-party-inventory-service"
  tenantservice_tag = "third-party-inventory"
}