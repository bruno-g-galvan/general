lz_vpc_name = "PrimaryVPCProperSubnets"

aws_region = "us-west-2"
route53_zone_name = "stable.us-west-2.aws.groupondev.com."
subnetid_b = "subnet-0fcf3c3d4b337cc4f" # us-west-2b-AppSubnet
legacy_subnets = true

                          # SNC1(1)         SNC1(2)         SAC1            DUB1            VPN-DUB1        VPN-SAC1        VPN-SNC1
raas-allow-onprem = ["10.20.0.0/14", "10.24.0.0/15", "10.32.0.0/14", "10.12.0.0/14", "10.37.0.0/16", "10.36.0.0/16", "10.60.0.0/16"]
cloud-jenkins-subnets = ["10.224.48.0/20"] # usw2 - Stable