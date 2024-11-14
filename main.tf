resource "azurerm_web_application_firewall_policy" "this" {
  name                = var.config.name
  resource_group_name = coalesce(lookup(var.config, "resource_group", null), var.resource_group)
  location            = coalesce(lookup(var.config, "location", null), var.location)
  tags                = try(var.config.tags, var.tags, {})

  dynamic "custom_rules" {
    for_each = try(
      var.config.custom_rules, {}
    )

    content {
      action               = custom_rules.value.action
      priority             = custom_rules.value.priority
      rule_type            = custom_rules.value.rule_type
      name                 = try(custom_rules.value.name, null)
      enabled              = try(custom_rules.value.enabled, null)
      group_rate_limit_by  = try(custom_rules.value.group_rate_limit_by, null)
      rate_limit_duration  = try(custom_rules.value.rate_limit_duration, null)
      rate_limit_threshold = try(custom_rules.value.rate_limit_threshold, null)

      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions

        content {
          dynamic "match_variables" {
            for_each = match_conditions.value.match_variables

            content {
              variable_name = match_variables.value.variable_name
              selector      = try(match_variables.value.selector, null)
            }
          }
          operator           = match_conditions.value.operator
          negation_condition = try(match_conditions.value.negation_condition, null)
          match_values       = try(match_conditions.value.match_values, [])
          transforms         = try(match_conditions.value.transforms, null)
        }
      }
    }
  }

  dynamic "managed_rules" {
    for_each = lookup(var.config, "managed_rules", null) != null ? [var.config.managed_rules] : []
    content {
      dynamic "managed_rule_set" {
        for_each = try(managed_rules.value.managed_rule_sets, {})
        content {
          version = try(managed_rule_set.value.version, "2.1")
          type    = try(managed_rule_set.value.type, null)

          dynamic "rule_group_override" {
            for_each = try(managed_rule_set.value.rule_group_overrides, {})
            content {
              rule_group_name = rule_group_override.value.rule_group_name
              dynamic "rule" {
                for_each = try(rule_group_override.value.rules, {})
                content {
                  id      = rule.value.id
                  action  = try(rule.value.action, null)
                  enabled = try(rule.value.enabled, null)
                }
              }
            }
          }
        }
      }

      dynamic "exclusion" {
        for_each = try(managed_rules.value.exclusions, {})
        content {
          selector                = exclusion.value.selector
          match_variable          = exclusion.value.match_variable
          selector_match_operator = exclusion.value.selector_match_operator

          dynamic "excluded_rule_set" {
            for_each = lookup(exclusion.value, "excluded_rule_set", null) != null ? [exclusion.value.excluded_rule_set] : []
            content {
              type    = try(excluded_rule_set.value.type, null)
              version = try(excluded_rule_set.value.version, null)

              dynamic "rule_group" {
                for_each = try(excluded_rule_set.value.rule_groups, {})
                content {
                  rule_group_name = rule_group.value.rule_group_name
                  excluded_rules  = try(rule_group.value.excluded_rules, [])
                }
              }
            }
          }
        }
      }
    }
  }
}
