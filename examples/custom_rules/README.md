# Custom Rules

This deploys custom rules on web application firewall policy.

```hcl
config = object({
  name = string
  resource_group = string
  location = string
  managed_rules = object({
    managed_rule_sets = map(object({
      version = optional(string, "2.1")
      type = optional(string)
    }))
  })
  custom_rules = optional(map(object({
    name = optional(string)
    priority = number
    rule_type = string
    action = string
    enabled = optional(bool)
    rate_limit_duration = optional(string)
    rate_limit_threshold = optional(number)
    group_rate_limit_by = optional(string)
    match_conditions = map(object({
      match_variables = map(object({
        variable_name = string
        selector = optional(string)
      }))
      operator = string
      match_values = list(string)
      transforms = optional(list(string))
    }))
  })))
})
```
