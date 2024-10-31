variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

# variable "access_context_manager_policy_id" {
#   type        = number
#   description = "The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
# }

# variable "domain" {
#   type        = string
#   description = "The DNS name of peering managed zone, for instance 'example.com.'. Must end with a period."
# }

variable "egress_policies" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) to use in an enforced perimeter. Each list object has a `from` and `to` value that describes egress_from and egress_to.\n\nExample: `[{ from={ identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "egress_policies_dry_run" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) to use in a dry-run perimeter. Each list object has a `from` and `to` value that describes egress_from and egress_to.\n\nExample: `[{ from={ identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "ingress_policies" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference) to use in an enforced perimeter. Each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "ingress_policies_dry_run" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference) to use in a dry-run perimeter. Each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

# variable "perimeter_additional_members" {
#   description = "The list of additional members to be added to the enforced perimeter access level members list. To be able to see the resources protected by the VPC Service Controls in the restricted perimeter, add your user in this list. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`."
#   type        = list(string)
#   default     = []
# }

# variable "perimeter_additional_members_dry_run" {
#   description = "The list of additional members to be added to the dry-run perimeter access level members list. To be able to see the resources protected by the VPC Service Controls in the restricted perimeter, add your user in this list. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`."
#   type        = list(string)
#   default     = []
# }

# variable "tfc_org_name" {
#   description = "Name of the TFC organization"
#   type        = string
#   default     = ""
# }
