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
  instance_type       = "db.r6g.2xlarge"
  local_replica_cnt = 2
  local_subnet_group  = "sgroup-1"
  size                = "large"
  db_name			  = "vis20_emea_prod"
  cname			= "vis20-emea-prod"
  engine			  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.2"	
  multi_az			  = true
  port				  = 3306
  account_id = get_aws_account_id()
  performance_insights_enabled = true
  cluster_master_arn  = ""
  jira_tag = "GDS-19966"
  service_tag        = "daas_mysql"
  owner_tag          = "gds@groupon.com"
  tenantteam_tag = "voucher-inventory-dev@groupon.com"
  tenantservice_tag = "voucher-inventory"
}