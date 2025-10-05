########################### terraformConfiguration #########################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
  # backend "s3" {}
  # This is a placeholder for the actual backend configuration under ./env
  backend "local" {
    path = "./local.tfstate"
  }
}

########################### providerConfiguration #########################################
provider "aws" {
  region = local.region
}

############################## localVariables ############################################
locals {
  inputs = var.inputs.values
  region = "eu-central-1"
}

########################################## Modules ##########################################
module "vpc" {
  source   = "./aws-modules/vpc"
  for_each = try(local.inputs.vpc, {}) != {} ? { for s in local.inputs.vpc : s.vpc_id => s } : {}

  vpc = merge(
    {
      values               = each.value
      cidr_block           = each.value.cidr_block
      enable_dns_hostnames = each.value.enable_dns_hostnames
      resource_group_id    = each.value.enable_dns_support
      tags                 = try(merge(try(each.value.tags, {}), try(local.inputs.tags, {})), {})
    }
  )
}
