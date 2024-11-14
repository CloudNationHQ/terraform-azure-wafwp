# Default

This example illustrates the default setup, in its simplest form.

## Types


```hcl
config = object({
  name           = string
  resource_group = string
  location       = string
  managed_rules = object({
    managed_rule_sets = map(object({
      version = optional(string, "2.1")
      type = optional(string)
    }))
  })
  policy_settings = map({
    enabled = optional(bool, true)
    mode = optional(string, "Prevention")
    file_upload_limit_in_mb = optional(number, 100)
    request_body_check = optional(bool, true)
    max_request_body_size_in_kb = optional(number, 128)
    request_body_enforcement = optional(bool, true)
    request_body_inspect_limit_in_kb = optional(number, 128)
    js_challenge_cookie_expiration_in_minutes = optional(number, 30)
    file_upload_enforcement = optional(bool, true)
  })
})
```
