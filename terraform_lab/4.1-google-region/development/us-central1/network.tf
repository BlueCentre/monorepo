# NOTE: This module depends on the vpc module in google-project outputs
# chrome://bookmarks/?id=5910
# https://cloud.google.com/architecture/security-foundations/networking#ip-address-allocation
# https://console.cloud.google.com/networking/networks/list?project=prj-lab-james-nguyen&supportedpurview=project&pageTab=CURRENT_PROJECT_SUBNETS
# https://github.com/terraform-google-modules/terraform-google-network/tree/master/modules/subnets
module "vpc_subnet" {
  # for_each     = local.env_list # terraform state mv 'module.vpc_test[0].google_compute_network.network' 'module.vpc_test["dev"].google_compute_network.network'
  count        = local.active ? 1 : 0
  source       = "terraform-google-modules/network/google//modules/subnets"
  version      = "~> 9.1"
  project_id   = var.project_id
  network_name = local.network_name

  # 1. Subnets may not overlap
  # 2. Cannot remove a subnet while it is in use
  # 3. When extending range (12 newbit to 10 newbit; apply will modify even when in-use)
  # 4. When contracting range (10 newbit to 12 newbit; apply will destroy/create only if not in-use)
  # 5. While you can modify a subnet offset, Terraform will destroy and create a new subnet if not in-use
  # 6. Removing a subnet will remove all secondary ranges associated even if the ranges are still mapped in secondary_ranges below
  # 7. A simple description change will destroy/create the subnet

  # 10.0.0.0/8 (255.0.0.0) private range with 16,777,216 available addresses : https://en.wikipedia.org/wiki/Private_network
  # 2^12 newbits = 4096 offsets/subnets = /20 network = 4096 IPs per subnet
  # 2^10 newbits = 1024 offsets/subnets = /18 network = 16384 IPs per subnet
  # 2^8 newbits  = 256 offsets/subnets  = /16 network = 65536 IPs per subnet
  # 2^6 newbits  = 64 offsets/subnets   = /14 network = 262144 IPs per subnet
  # Usage: cidrsubnet("10.0.0.0/8", NEWBIT, OFFSET)
  subnets = [
    {
      subnet_name           = "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-0"
      subnet_ip             = cidrsubnet("10.0.0.0/8", 12, 0) # Can only expand network by descreasing newbits; if in-use, you cannot contract at all
      subnet_region         = var.region
      subnet_private_access = "true"
      description           = "Terraform managed: google-region" # Cannot change once in-use; otherwise TF will destroy/create
    },
    {
      subnet_name           = "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"
      subnet_ip             = cidrsubnet("10.0.0.0/8", 12, var.instance_number)
      subnet_region         = var.region
      subnet_private_access = "true"
      description           = "Terraform managed: google-region"
    },
    {
      subnet_name           = "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-22"
      subnet_ip             = cidrsubnet("10.0.0.0/8", 12, 22)
      subnet_region         = var.region
      subnet_private_access = "true"
      description           = "Terraform managed: google-region"
    },
    {
      subnet_name           = "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-23"
      subnet_ip             = cidrsubnet("10.0.0.0/8", 12, 23)
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      role                  = "ACTIVE"
      description           = "Terraform managed: google-region"
    },
    {
      subnet_name                  = "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-24"
      subnet_ip                    = cidrsubnet("10.0.0.0/8", 12, 24)
      subnet_region                = var.region
      subnet_flow_logs             = "true"
      subnet_flow_logs_interval    = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling    = 0.7
      subnet_flow_logs_metadata    = "INCLUDE_ALL_METADATA"
      subnet_flow_logs_filter_expr = "true"
      description                  = "Terraform managed: google-region"
    }
  ] # END: subnets

  # 1. Secondary ranges may not overlap even across different subnets
  # 2. Cannot add and remove secondary on the same terraform apply
  # 3. Cannot modify the secondary range once created
  # 4. While you can remove N number of secondary ranges, Terraform will not perform any action if all ranges are removed in one apply
  # 5. Terraform refuses to remove the last secondary so this will have to be performed in the console if the intent is to empty all secondary from subnet
  # 6. If subnet does not exist, Terraform takes no action

  # 172.16.0.0/12 (255.240.0.0)
  # 172.16.0.0-172.31.255.255 private range with 1,048,576 available addresses : https://en.wikipedia.org/wiki/Private_network
  # 2^8 newbits = (256 subnets/offsets) = /20 network = 4096 IPs per subnet
  # 2^6 newbits = (64 subnets/offsets)  = /18 network = 16384 IPs per subnet
  # 2^4 newbits = (16 subnets/offsets)  = /16 network = 65536 IPs per subnet
  # 2^2 newbits = (4 subnets/offsets)   = /14 network = 262144 IPs per subnet
  # Usage: cidrsubnet("172.16.0.0/12", NEWBIT, OFFSET)
  # https://docs.google.com/spreadsheets/d/17TxvIHJZaD5eT4orMh_E6i3kYRnIf_Ov_F_o7px3IPo/edit?gid=0#gid=0
  secondary_ranges = {
    # Potentially reserved for Platform GKE workloads
    "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-0" = [
      {
        range_name    = "pod-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 4, 0) # 0-15 offset
      },
      {
        range_name    = "svc-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, 63) # 0-63 offset
      },
    ]
    # GKE cluster with roughly 65536 available pod IPs and 16384 service IPs for GKE workloads
    "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}" = [
      {
        range_name    = "pod-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 4, var.instance_number) # 0-15 offset # cidrsubnet("172.16.0.0/12", 2, 3) # 0-3 offset
      },
      {
        range_name    = "svc-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, (63 - var.instance_number)) # 0-63 offset
      },
    ]
    # GKE cluster with roughly 16384 available pod IPs and 16384 service IPs for GKE workloads
    "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-22" = [ #]
      {
        range_name    = "pod-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, 22) # 0-63 offset
      },
      {
        range_name    = "svc-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, (63 - 22)) # 0-63 offset
      },
    ]
    # GKE cluster with additional secondary ranges for GKE workloads that needed expansion
    "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-23" = [ #]
      # Uncomment to see error that range conflicts with range in subnet with offset 22
      # {
      #   range_name    = "invalid-${local.env_code}-${var.project_id}-${var.region}-23"
      #   ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, 22) # Already used in *-22 subnet above
      # },
      {
        range_name    = "pod-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, 23)
      },
      {
        range_name    = "svc-${local.env_code}-${var.project_id}-${var.region}-0"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, (63 - 23))
      },
      {
        range_name    = "pod-${local.env_code}-${var.project_id}-${var.region}-1"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, 24)
      },
      {
        range_name    = "svc-${local.env_code}-${var.project_id}-${var.region}-1"
        ip_cidr_range = cidrsubnet("172.16.0.0/12", 6, (63 - 24))
      },
    ]
    # Potentially use for non-GKE workloads such as Cloud Run, App Engine, Dataflow, etc. Therefore we will not use the secondary range.
    "sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-24" = []
  } # END: secondary_ranges
}   # END: module.vpc_subnet

resource "google_compute_address" "nat_external_static_ip" {
  count        = local.active && var.enable_whitelist_ip ? 1 : 0
  project      = var.project_id
  name         = "nat-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}"
  address_type = "EXTERNAL"
  description  = "Reserved external static IP address used by Cloud NAT for customer whitelist"
}

module "cloud_router" {
  count   = local.active && var.enable_whitelist_ip ? 1 : 0
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  project = var.project_id
  network = local.network_name
  region  = var.region
  name    = "cr-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}"
  bgp = {
    # The ASN (16550, 64512 - 65534, 4200000000 - 4294967294) can be any private ASN
    # not already used as a peer ASN in the same region and network or 16550 for Partner Interconnect.
    asn = "65001"
  }
  # description  = "Terraform managed: google-region"
  nats = [{
    name                               = "nat-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}"
    nat_ip_allocate_option             = "MANUAL_ONLY"         # "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS" # "ALL_SUBNETWORKS_ALL_IP_RANGES" 
    # nat_ips                            = [var.enable_whitelist_ip ? google_compute_address.nat_external_static_ip[count.index].self_link : data.google_compute_address.nat_external_static_ip[count.index].self_link]
    # nat_ips                            = [var.enable_whitelist_ip ? google_compute_address.nat_external_static_ip[count.index].self_link : null]
    nat_ips                        = [google_compute_address.nat_external_static_ip[count.index].self_link]
    min_ports_per_vm               = "8192"
    enable_dynamic_port_allocation = true
    subnetworks = [
      # {
      #   name                    = module.vpc_subnet[count.index].subnets["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].id
      #   source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
      # }
      {
        name                     = module.vpc_subnet[count.index].subnets["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].id
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = module.vpc_subnet[count.index].subnets["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].secondary_ip_range[*].range_name
      }
    ]
  }]
}
