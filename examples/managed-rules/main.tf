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
    location       = "westeurope"

    managed_rules = {
      managed_rule_set = {
        version = "3.2"
        type    = "OWASP"

        rule_group_overrides = {
          sql_injection = {
            rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
            rules = {
              rule1 = {
                id      = "942200"
                enabled = false
              }
              rule2 = {
                id     = "942210"
                action = "Log"
              }
            }
          }
        }
      }

      exclusions = {
        api_endpoint = {
          match_variable          = "RequestArgValues"
          selector                = "/api/v1/special-endpoint"
          selector_match_operator = "Contains"
          excluded_rule_set = {
            type    = "OWASP"
            version = "3.2"
            rule_groups = {
              sqli = {
                rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
                excluded_rules  = ["942200", "942210", "942260"]
              }
            }
          }
        }

        custom_header = {
          match_variable          = "RequestHeaderValues"
          selector                = "x-custom-header"
          selector_match_operator = "Equals"
          excluded_rule_set = {
            type    = "OWASP"
            version = "3.2"
            rule_groups = {
              xss = {
                rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
                excluded_rules  = ["941320"]
              }
            }
          }
        }
      }
    }
  }
}
