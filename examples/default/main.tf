module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "policy" {
  source = "../../"

  config = {
    name           = "waf-policy"
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location

    managed_rules = {
      managed_rule_set = {
        version = "3.2"
        type    = "OWASP"
      }
    }
  }
}
