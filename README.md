# Web Appliation Firewall Policy

This Terraform module manages Azure web application firewall policies, providing flexible rule configurations, request validation settings, and seamless integration with application gateway for enhanced security and traffic management.

## Features

Flexible support for custom and managed rulesets and rules

Rate limiting and geo-filtering capabilities

Configurable OWASP rules and bot protection

Advanced request validation and match conditions

Rule exclusions and overrides support

Adjustable request body inspection

Customizable rule actions and responses

Integrates with application gateway

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_web_application_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: Contains all Web Application Firewall policy configuration

Type:

```hcl
object({
    name                = string
    resource_group_name = optional(string, null)
    location            = optional(string, null)
    tags                = optional(map(string))
    policy_settings = optional(object({
      enabled                                   = optional(bool, true)
      mode                                      = optional(string, "Prevention")
      file_upload_limit_in_mb                   = optional(number, 100)
      request_body_check                        = optional(bool, true)
      max_request_body_size_in_kb               = optional(number, 128)
      request_body_enforcement                  = optional(bool, true)
      request_body_inspect_limit_in_kb          = optional(number, 128)
      js_challenge_cookie_expiration_in_minutes = optional(number, 30)
      file_upload_enforcement                   = optional(bool, null)
    }), null)
    custom_rules = optional(map(object({
      action               = string
      priority             = number
      rule_type            = string
      name                 = optional(string, null)
      enabled              = optional(bool, null)
      group_rate_limit_by  = optional(string, null)
      rate_limit_duration  = optional(string, null)
      rate_limit_threshold = optional(number, null)
      match_conditions = map(object({
        match_variables = map(object({
          variable_name = string
          selector      = optional(string, null)
        }))
        operator           = string
        negation_condition = optional(bool, null)
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
            enabled = optional(bool, null)
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_firewall_policy"></a> [firewall\_policy](#output\_firewall\_policy)

Description: contains web application fireqwall policy configuration
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-wafwp/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-wafwp" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/web-application-firewall/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/application-gateway/web-application-firewall-policies)
