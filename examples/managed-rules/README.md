# Managed Rules

This deploys managed rules on web application firewall policy.

```hcl
config = object({
  name           = string
  resource_group = string
  location       = string
  managed_rules = object({
    managed_rule_sets = map(object({
      version = string
      type    = string
      rule_group_overrides = optional(map(object({
        rule_group_name = string
        rules = optional(map(object({
          id      = optional(string)
          enabled = optional(bool)
          action  = optional(string)
        })))
      })))
    }))
    exclusions = optional(map(object({
      match_variable          = string
      selector               = string
      selector_match_operator = string
      excluded_rule_set = optional(object({
        type    = string
        version = string
        rule_groups = optional(map(object({
          rule_group_name = string
          excluded_rules  = list(string)
        })))
      }))
    })))
  })
})
```
