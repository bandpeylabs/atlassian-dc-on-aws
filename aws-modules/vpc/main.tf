############################## localVariables ############################################
locals {
  vpc = var.vpc
}

############################ defaultDataSources ##########################################
data "aws_region" "current" {}

################################ Resources ###############################################
resource "aws_vpc" "main" {
  cidr_block           = local.vpc.cidr_block
  enable_dns_hostnames = try(local.vpc.enable_dns_hostnames, true)
  enable_dns_support   = try(local.vpc.enable_dns_support, true)

  tags = merge(
    try(local.vpc.tags, {})
  )
}
