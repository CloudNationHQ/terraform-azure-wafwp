# Default

This example illustrates the default setup, in its simplest form.

## Types


```hcl
config = object({
  name           = string
  resource_group = string
  location       = string
  managed_rules  = object({
    managed_rule_set = object({
      version = string
      type    = string
    })
  })
})
```
