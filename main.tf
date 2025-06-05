resource "azurerm_web_application_firewall_policy" "this" {
  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  name = var.config.name

  tags = coalesce(
    var.config.tags, var.tags
  )

  dynamic "policy_settings" {
    for_each = lookup(var.config, "policy_settings", null) != null ? [var.config.policy_settings] : []

    content {
      enabled                                   = policy_settings.value.enabled
      mode                                      = policy_settings.value.mode
      file_upload_limit_in_mb                   = policy_settings.value.file_upload_limit_in_mb
      request_body_check                        = policy_settings.value.request_body_check
      max_request_body_size_in_kb               = policy_settings.value.max_request_body_size_in_kb
      request_body_enforcement                  = policy_settings.value.request_body_enforcement
      request_body_inspect_limit_in_kb          = policy_settings.value.request_body_inspect_limit_in_kb
      js_challenge_cookie_expiration_in_minutes = policy_settings.value.js_challenge_cookie_expiration_in_minutes
      file_upload_enforcement                   = policy_settings.value.file_upload_enforcement

      dynamic "log_scrubbing" {
        for_each = try(policy_settings.value.log_scrubbing, null) != null ? [policy_settings.value.log_scrubbing] : []

        content {
          enabled = log_scrubbing.value.enabled

          dynamic "rule" {
            for_each = try(
              log_scrubbing.value.rules, []
            )

            content {
              enabled                 = rule.value.enabled
              match_variable          = rule.value.match_variable
              selector_match_operator = rule.value.selector_match_operator
              selector                = rule.value.selector
            }
          }
        }
      }
    }
  }

  dynamic "custom_rules" {
    for_each = try(
      var.config.custom_rules, {}
    )

    content {
      name = coalesce(
        custom_rules.value.name, custom_rules.key
      )

      action               = custom_rules.value.action
      priority             = custom_rules.value.priority
      rule_type            = custom_rules.value.rule_type
      enabled              = custom_rules.value.enabled
      group_rate_limit_by  = custom_rules.value.group_rate_limit_by
      rate_limit_duration  = custom_rules.value.rate_limit_duration
      rate_limit_threshold = custom_rules.value.rate_limit_threshold

      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions

        content {
          dynamic "match_variables" {
            for_each = match_conditions.value.match_variables

            content {
              variable_name = match_variables.value.variable_name
              selector      = match_variables.value.selector
            }
          }
          operator           = match_conditions.value.operator
          negation_condition = match_conditions.value.negation_condition
          match_values       = match_conditions.value.match_values
          transforms         = match_conditions.value.transforms
        }
      }
    }
  }

  dynamic "managed_rules" {
    for_each = lookup(var.config, "managed_rules", null) != null ? [var.config.managed_rules] : []

    content {
      dynamic "managed_rule_set" {
        for_each = try(
          managed_rules.value.managed_rule_sets, {}
        )

        content {
          version = managed_rule_set.value.version
          type    = managed_rule_set.value.type

          dynamic "rule_group_override" {
            for_each = try(
              managed_rule_set.value.rule_group_overrides, {}
            )

            content {
              rule_group_name = rule_group_override.value.rule_group_name

              dynamic "rule" {
                for_each = try(
                  rule_group_override.value.rules, {}
                )

                content {
                  id      = rule.value.id
                  action  = rule.value.action
                  enabled = rule.value.enabled
                }
              }
            }
          }
        }
      }

      dynamic "exclusion" {
        for_each = try(
          managed_rules.value.exclusions, {}
        )

        content {
          selector                = exclusion.value.selector
          match_variable          = exclusion.value.match_variable
          selector_match_operator = exclusion.value.selector_match_operator

          dynamic "excluded_rule_set" {
            for_each = lookup(exclusion.value, "excluded_rule_set", null) != null ? [exclusion.value.excluded_rule_set] : []

            content {
              type    = excluded_rule_set.value.type
              version = excluded_rule_set.value.version

              dynamic "rule_group" {
                for_each = try(
                  excluded_rule_set.value.rule_groups, {}
                )

                content {
                  rule_group_name = rule_group.value.rule_group_name
                  excluded_rules  = rule_group.value.excluded_rules
                }
              }
            }
          }
        }
      }
    }
  }
}
