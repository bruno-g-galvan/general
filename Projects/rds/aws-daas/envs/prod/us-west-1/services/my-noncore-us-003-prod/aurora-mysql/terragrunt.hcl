terraform {
    source = "../../../../../../modules/aurora-mysql"
}

include {
	path = find_in_parent_folders()
}

dependencies {
	paths = [
  		"../../../database/networking",
#     	"../../../database/options",
  		"../../../database/parameters/aurora/5.7",
  		"../../../database/security",
	]
}


# If module specific variables need to be defined, these variables need to be defined in a "module-specific.tfvars" file inside the same directory

inputs = {
  instance_type       = "db.t4g.large"
  backup_retention_period = 15
  local_replica_cnt = 0
  local_subnet_group  = "sgroup-1"
  size                = "small"
  db_name			  = "my_noncore_us_003_prod"
  engine			  = "aurora-mysql"
  engine_version	  = "5.7.mysql_aurora.2.11.2"
  multi_az			  = true
  port				  = 3306
  apply_immediately = true
  performance_insights_enabled = true
  storage_encrypted = true
  cluster_master_arn  = ""
  account_id  = get_aws_account_id()
  cname = "my-noncore-us-003-prod"
  maintenance_window  = "mon:00:00-mon:03:00"
  jira_tag = "GDS-28711"
  service_tag        = "daas_mysql"
  owner_tag          = "gds@groupon.com"
  tenantteam_tag = "gds@groupon.com"
  tenantservice_tag = "multi-tenant"
}