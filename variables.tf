variable "oracle_compartment_id" {
    description = "The OCID of the compartment to create the nodes in"
}

variable "oracle_account_email" {
    description = "The email of the Oracle Cloud account"
}

variable "oracle_tenancy_ocid" {
    description = "The OCID of the tenancy to create the nodes in"
}

variable "oracle_user_ocid" {
    description = "The OCID of the user to create the nodes in"
}

variable "oracle_fingerprint" {
    description = "The fingerprint of the user to create the nodes in"
}
variable "oracle_private_key" {
    description = "The private key of the user to create the nodes in"
}
variable "oracle_region" {
    description = "The region to create the nodes in"
}

variable "subnet_id" {
    description = "The OCID of the subnet to create the nodes in"
}

variable "network_security_group_id" {
    description = "The OCID of the security group
}