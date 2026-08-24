variable "policy" {
  description = "contains all web application firewall policy configuration"
  type = object({
    name                = string
    resource_group_name = optional(string, null)
    location            = optional(string, null)
    tags                = optional(map(string))
    policy_settings = optional(object({
      enabled                                   = optional(bool)
      mode                                      = optional(string, "Prevention")
      file_upload_limit_in_mb                   = optional(number, 100)
      request_body_check                        = optional(bool)
      max_request_body_size_in_kb               = optional(number, 128)
      request_body_enforcement                  = optional(bool)
      request_body_inspect_limit_in_kb          = optional(number, 128)
      js_challenge_cookie_expiration_in_minutes = optional(number, 30)
      file_upload_enforcement                   = optional(bool)
      log_scrubbing = optional(object({
        enabled = optional(bool)
        rules = optional(map(object({
          enabled                 = optional(bool)
          match_variable          = string
          selector_match_operator = optional(string, "Equals")
          selector                = optional(string)
        })), {})
      }))
    }), null)
    custom_rules = optional(map(object({
      action               = string
      priority             = number
      rule_type            = string
      name                 = optional(string, null)
      enabled              = optional(bool)
      group_rate_limit_by  = optional(string, null)
      rate_limit_duration  = optional(string, null)
      rate_limit_threshold = optional(number, null)
      match_conditions = map(object({
        match_variables = map(object({
          variable_name = string
          selector      = optional(string, null)
        }))
        operator           = string
        negation_condition = optional(bool)
        match_values       = optional(list(string), [])
        transforms         = optional(list(string), null)
      }))
    })), {})
    managed_rules = optional(object({
      managed_rule_sets = optional(map(object({
        version = optional(string, null)
        type    = optional(string, null)
        rule_group_overrides = optional(map(object({
          rule_group_name = string
          rules = optional(map(object({
            id      = string
            action  = optional(string, null)
            enabled = optional(bool)
          })), {})
        })), {})
      })), {})
      exclusions = optional(map(object({
        selector                = string
        match_variable          = string
        selector_match_operator = string
        excluded_rule_set = optional(object({
          type    = optional(string, null)
          version = optional(string, null)
          rule_groups = optional(map(object({
            rule_group_name = string
            excluded_rules  = optional(list(string), [])
          })), {})
        }), null)
      })), {})
    }), null)
  })
  validation {
    condition     = lookup(var.policy, "location", null) != null || var.location != null
    error_message = "location must be set on var.policy.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.policy, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.policy.resource_group_name or on the module-level var.resource_group_name."
  }

}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}
