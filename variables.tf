variable "redhat_openshift_clusters" {
  description = <<EOT
Map of redhat_openshift_clusters, attributes below
Required:
    - location
    - name
    - resource_group_name
    - api_server_profile (block):
        - visibility (required)
    - cluster_profile (block):
        - domain (required)
        - fips_enabled (optional)
        - managed_resource_group_name (optional)
        - pull_secret (optional)
        - version (required)
    - ingress_profile (block):
        - visibility (required)
    - main_profile (block):
        - disk_encryption_set_id (optional)
        - encryption_at_host_enabled (optional)
        - subnet_id (required)
        - vm_size (required)
    - network_profile (block):
        - load_balancer_profile (optional, block):
            - managed_outbound_ip_count (required)
        - outbound_type (optional)
        - pod_cidr (required)
        - preconfigured_network_security_group_enabled (optional)
        - service_cidr (required)
    - worker_profile (block):
        - disk_encryption_set_id (optional)
        - disk_size_gb (required)
        - encryption_at_host_enabled (optional)
        - node_count (required)
        - subnet_id (required)
        - vm_size (required)
Optional:
    - tags
    - identity (block):
        - identity_ids (required)
        - type (required)
    - platform_workload_identity_profile (block):
        - platform_workload_identity (required, block):
            - identity_id (required)
            - name (required)
        - upgradeable_to (optional)
    - service_principal (block):
        - client_id (required)
        - client_secret (required)
EOT

  type = map(object({
    location            = string
    name                = string
    resource_group_name = string
    tags                = optional(map(string))
    api_server_profile = object({
      visibility = string
    })
    cluster_profile = object({
      domain                      = string
      fips_enabled                = optional(bool)
      managed_resource_group_name = optional(string)
      pull_secret                 = optional(string)
      version                     = string
    })
    ingress_profile = object({
      visibility = string
    })
    main_profile = object({
      disk_encryption_set_id     = optional(string)
      encryption_at_host_enabled = optional(bool)
      subnet_id                  = string
      vm_size                    = string
    })
    network_profile = object({
      load_balancer_profile = optional(object({
        managed_outbound_ip_count = number
      }))
      outbound_type                                = optional(string)
      pod_cidr                                     = string
      preconfigured_network_security_group_enabled = optional(bool)
      service_cidr                                 = string
    })
    worker_profile = object({
      disk_encryption_set_id     = optional(string)
      disk_size_gb               = number
      encryption_at_host_enabled = optional(bool)
      node_count                 = number
      subnet_id                  = string
      vm_size                    = string
    })
    identity = optional(object({
      identity_ids = set(string)
      type         = string
    }))
    platform_workload_identity_profile = optional(object({
      platform_workload_identity = list(object({
        identity_id = string
        name        = string
      }))
      upgradeable_to = optional(string)
    }))
    service_principal = optional(object({
      client_id     = string
      client_secret = string
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.redhat_openshift_clusters : (
        v.platform_workload_identity_profile == null || (length(v.platform_workload_identity_profile.platform_workload_identity) >= 1)
      )
    ])
    error_message = "Each platform_workload_identity list must contain at least 1 items"
  }
}

