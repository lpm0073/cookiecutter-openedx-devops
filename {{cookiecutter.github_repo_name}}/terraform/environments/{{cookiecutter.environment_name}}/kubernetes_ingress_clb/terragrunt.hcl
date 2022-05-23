#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: Mar-2022
#
# usage: build an EKS with EC2 worker nodes and ALB
#------------------------------------------------------------------------------
locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("{{ cookiecutter.global_platform_shared_resource_identifier }}.hcl"))
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Extract out common variables for reuse
  env                             = local.environment_vars.locals.environment
  environment_domain              = local.environment_vars.locals.environment_domain
  namespace                       = local.environment_vars.locals.shared_resource_namespace
  root_domain                     = local.global_vars.locals.root_domain
  platform_name                   = local.global_vars.locals.platform_name
  platform_region                 = local.global_vars.locals.platform_region
  account_id                      = local.global_vars.locals.account_id
  aws_region                      = local.global_vars.locals.aws_region

  tags = merge(
    local.environment_vars.locals.tags,
    local.global_vars.locals.tags,
    { Name = "${local.namespace}-eks-ingress" }
  )
}

dependencies {
  paths = ["../vpc", "../kubernetes"]
}


# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../modules//kubernetes_ingress_clb"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  aws_region = local.aws_region
  environment_domain = local.environment_domain
  root_domain = local.root_domain
  namespace = local.namespace
  private_subnet_ids = dependency.vpc.outputs.private_subnets
  public_subnet_ids = dependency.vpc.outputs.public_subnets
  vpc_id  = dependency.vpc.outputs.vpc_id
  tags = local.tags
}
