provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "solidaeon-tfstate-main"
    region = "ap-northeast-1"
    key = "vpc/vpc.tfstate"
  }
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = var.namespace
  name       = "vpc"
  stage      = var.stage
  cidr_block = var.cidr_block
}

locals {
  public_cidr_block  = cidrsubnet(module.vpc.vpc_cidr_block, 1, 0)
  private_cidr_block = cidrsubnet(module.vpc.vpc_cidr_block, 1, 1)
}

module "public_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = var.namespace
  stage               = var.stage
  name                = var.name
  availability_zones  = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = local.public_cidr_block
  type                = "public"
  igw_id              = module.vpc.igw_id
  nat_gateway_enabled = "true"
}

module "private_subnets" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = var.namespace
  stage               = var.stage
  name                = var.name
  availability_zones  = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = local.private_cidr_block
  type                = "private"
  az_ngw_ids          = module.public_subnets.az_ngw_ids
}

output "private_az_subnet_ids" {
  value = module.private_subnets.az_subnet_ids
}

output "public_az_subnet_ids" {
  value = module.public_subnets.az_subnet_ids
}