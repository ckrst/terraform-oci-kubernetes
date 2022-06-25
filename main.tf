
provider "oci" {
  tenancy_ocid = var.oracle_tenancy_ocid
  user_ocid    = var.oracle_user_ocid
  fingerprint  = var.oracle_fingerprint
  private_key  = var.oracle_private_key
  region       = var.oracle_region
}

locals {
  initial_setup = <<EOF
#!/bin/bash
whoami
apt update
apt install firewalld -y
snap install microk8s --classic
microk8s status --wait-ready
iptables-save > ~/iptables-rules
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=10443/tcp
firewall-cmd --zone=public --permanent --add-port=10250/tcp
firewall-cmd --zone=public --permanent --add-port=10255/tcp
firewall-cmd --zone=public --permanent --add-port=16443/tcp
firewall-cmd --zone=public --permanent --add-port=25000/tcp
firewall-cmd --zone=public --permanent --add-port=12379/tcp
firewall-cmd --zone=public --permanent --add-port=10257/tcp
firewall-cmd --zone=public --permanent --add-port=10259/tcp
firewall-cmd --zone=public --permanent --add-port=19001/tcp
firewall-cmd --zone=public --permanent --add-port=30000-33999/tcp
firewall-cmd --reload
EOF
}


resource "oci_core_instance" "controller_node" {
  availability_domain = var.oracle_availability_domain
  compartment_id      = var.oracle_compartment_id
  shape               = "VM.Standard.A1.Flex"
  defined_tags = {
    "Oracle-Tags.CreatedBy" = "oracleidentitycloudservice/${var.oracle_account_email}"
    # "Oracle-Tags.CreatedOn" = "2021-06-24T13:30:34.821Z"
  }
  display_name      = "microk8s Controller"
  extended_metadata = {}
  freeform_tags     = {}
  metadata = {
    ssh_authorized_keys = var.public_key
    user_data           = base64encode(local.initial_setup)

  }

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
  }

  availability_config {
    is_live_migration_preferred = false
    recovery_action             = "RESTORE_INSTANCE"
  }

  create_vnic_details {
    # assign_private_dns_record = false
    assign_public_ip = true
    defined_tags = {
      "Oracle-Tags.CreatedBy" = "oracleidentitycloudservice/${var.oracle_account_email}"
      # "Oracle-Tags.CreatedOn" = "2021-06-24T13:30:35.220Z"
    }
    display_name           = "microk8s Controller"
    freeform_tags          = {}
    hostname_label         = "microk8s-controller"
    nsg_ids                = [var.network_security_group_id]
    skip_source_dest_check = false
    subnet_id              = var.subnet_id
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = false
  }

  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = true
    is_pv_encryption_in_transit_enabled = true
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
  }

  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  source_details {
    boot_volume_size_in_gbs = "50"
    source_id               = "ocid1.image.oc1.iad.aaaaaaaaoomqgvfu6zd3dhtrilbvo2s7qhmlqiodcogoonhpc2kgl5qlhddq"
    # source_id = "ocid1.image.oc1.iad.aaaaaaaa2tex34yxzqunbwnfnat6pkh2ztqchvfyygnnrhfv7urpbhozdw2a"
    source_type = "image"
  }

  lifecycle {
    ignore_changes = [
      defined_tags,
      create_vnic_details,
      launch_options,
      metadata
    ]
  }
}


resource "oci_core_instance" "worker_node" {
  availability_domain = var.oracle_availability_domain
  compartment_id      = var.oracle_compartment_id
  shape               = "VM.Standard.A1.Flex"
  defined_tags = {
    "Oracle-Tags.CreatedBy" = "oracleidentitycloudservice/${var.oracle_account_email}"
    # "Oracle-Tags.CreatedOn" = "2021-06-24T13:30:34.821Z"
  }
  display_name      = "microk8s Node"
  extended_metadata = {}
  freeform_tags     = {}
  metadata = {
    ssh_authorized_keys = var.public_key
    user_data           = base64encode(local.initial_setup)
  }

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
  }

  availability_config {
    is_live_migration_preferred = false
    recovery_action             = "RESTORE_INSTANCE"
  }

  create_vnic_details {
    # assign_private_dns_record = false
    assign_public_ip = true
    defined_tags = {
      "Oracle-Tags.CreatedBy" = "oracleidentitycloudservice/${var.oracle_account_email}"
      # "Oracle-Tags.CreatedOn" = "2021-06-24T13:30:35.220Z"
    }
    display_name           = "microk8s Node"
    freeform_tags          = {}
    hostname_label         = "microk8s-node"
    nsg_ids                = [var.network_security_group_id]
    skip_source_dest_check = false
    subnet_id              = var.subnet_id
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = false
  }

  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = true
    is_pv_encryption_in_transit_enabled = true
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
  }

  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  source_details {
    boot_volume_size_in_gbs = "50"
    source_id               = "ocid1.image.oc1.iad.aaaaaaaaoomqgvfu6zd3dhtrilbvo2s7qhmlqiodcogoonhpc2kgl5qlhddq"
    # source_id = "ocid1.image.oc1.iad.aaaaaaaa2tex34yxzqunbwnfnat6pkh2ztqchvfyygnnrhfv7urpbhozdw2a"
    source_type = "image"
  }

  lifecycle {
    ignore_changes = [
      defined_tags,
      create_vnic_details,
      launch_options,
      metadata
    ]
  }
}