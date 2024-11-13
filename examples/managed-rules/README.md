# Managed Rules

This deploys managed rules on web application firewall policy.

```hcl
config = object({
  name = string
  resource_group = string
  location = string
  managed_rules = object({
    managed_rule_set = object({
      version = optional(string, "2.1")
      type = optional(string)
      rule_group_overrides = optional(map(object({
        rule_group_name = string
        rules = optional(map(object({
          id = string
          enabled = optional(bool)
          action = optional(string)
        })))
      })))
    })
    exclusions = optional(map(object({
      match_variable = string
      selector = string
      selector_match_operator = string
      excluded_rule_set = optional(object({
        type = optional(string)
        version = optional(string)
        rule_groups = optional(map(object({
          rule_group_name = string
          excluded_rules = optional(list(string), [])
        })))
      }))
    })))
  })
})
```
