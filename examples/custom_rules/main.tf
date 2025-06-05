module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

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
  version = "~> 2.0"

  config = {
    name                = module.naming.web_application_firewall_policy.name
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    policy_settings = {
      enabled = true
      mode    = "Prevention"
    }
    managed_rules = {
      managed_rule_sets = {
        owasp = {
          type    = "OWASP"
          version = "3.2"
        }
      }
    }

    custom_rules = {
      apiRateLimit = {
        priority             = 10
        rule_type            = "RateLimitRule"
        action               = "Block"
        enabled              = true
        rate_limit_duration  = "FiveMins"
        rate_limit_threshold = 1000
        group_rate_limit_by  = "ClientAddr"

        match_conditions = {
          condition1 = {
            match_variables = {
              var1 = {
                variable_name = "RequestUri"
              }
            }
            operator     = "Contains"
            match_values = ["/api/"]
          }
        }
      }

      blockBadBots = {
        priority  = 20
        rule_type = "MatchRule"
        action    = "Block"
        enabled   = true

        match_conditions = {
          condition1 = {
            match_variables = {
              var1 = {
                variable_name = "RequestHeaders"
                selector      = "User-Agent"
              }
            }
            operator     = "Contains"
            match_values = ["360Spider", "wget", "curl", "python-requests"]
            transforms   = ["Lowercase"]
          }
        }
      }

      geoBlocking = {
        priority  = 40
        rule_type = "MatchRule"
        action    = "Block"
        enabled   = true

        match_conditions = {
          condition1 = {
            match_variables = {
              var1 = {
                variable_name = "RemoteAddr"
              }
            }
            operator     = "GeoMatch"
            match_values = ["CN", "RU", "IR", "KP"]
          }
        }
      }

      suspiciousQueries = {
        priority  = 60
        rule_type = "MatchRule"
        action    = "Block"
        enabled   = true

        match_conditions = {
          condition1 = {
            match_variables = {
              var1 = {
                variable_name = "QueryString"
              }
            }
            operator     = "Contains"
            match_values = ["eval(", "execute(", "<script", "javascript:"]
            transforms   = ["Lowercase", "UrlDecode"]
          }
        }
      }
    }
  }
}
