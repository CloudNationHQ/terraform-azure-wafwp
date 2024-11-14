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
  source  = "cloudnationhq/wafwp/azure"
  version = "~> 1.0"

  config = {
    name           = module.naming.web_application_firewall_policy.name
    resource_group = module.rg.groups.demo.name
    location       = module.rg.groups.demo.location

    policy_settings = {
      enabled = true
      mode    = "Prevention"
    }

    managed_rules = {
      managed_rule_sets = {
        owasp = {
          version = "3.2"
          type    = "OWASP"
        }
      }
    }
  }
}
