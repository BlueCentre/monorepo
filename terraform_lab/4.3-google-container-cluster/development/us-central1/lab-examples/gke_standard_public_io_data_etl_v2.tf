locals {
  # MISCELLANEOUS
  product = "FusionRM"
  # environment              = lower(replace(var.environment, " ", "-"))
  client                 = "lab" # data.google_project.project.labels.client
  client_iata            = "JN"  # data.google_project.project.labels.client_iata
  client_iata_lower      = lower(local.client_iata)
  owner                  = "james"    #lower(replace(var.owner, " ", "-"))
  team                   = "platform" #lower(coalesce(var.team, local.owner))
  deployment_id          = "asdfghjj" # substr(random_uuid.etl_deployment_id.result, 0, 6)
  airflow_datbase_name   = "airflow"
  disable_customer_gcs   = true       # length(var.service_accounts_for_customer_bucket) == 0 ? true : false
  enable_customer_gcs_v2 = false      # length(var.customer_bucket_service_accounts) == 0 ? false : true
  region                 = var.region # var.environment != "prod" ? null : var.region
  multiregion            = "US"       # length(regexall("^us", var.region)) > 0 ? "US" : length(regexall("^europe", var.region)) > 0 ? "EU" : length(regexall("^asia", var.region)) > 0 ? "ASIA" : null
  # cloudfunction_region     = var.region == "europe-west4" ? "europe-west1" : var.region
  zone = null # var.environment != "prod" ? var.zone : null
  # common_view_stage        = var.environment == "prod" ? "prod" : "staging"
  # common_view_region       = var.common_view_region_override == null ? (length(regexall("^us", var.region)) > 0 ? "us" : "eu") : lower(replace(var.common_view_region_override, "-", "_"))
  # notification_channel_ids = [for item in [module.pagerduty_notification_channel.id, module.slack_notification_channel.id] : item if item != null]

  # default_database_version = "POSTGRES_12"

  # default_cloudsql_sftp_settings = {
  #   utc_backup_window_start_time = "2:00"
  #   maintenance_window           = { day = 6, hour = 8, update_track = "stable" }
  # }

  # sftp_cloudsql_settings = merge(local.default_cloudsql_sftp_settings, var.sftp_custom_cloudsql_settings)

  # GKE CLUSTER & NODE POOL
  # Setup defaults for GKE   #   local.default_gke_node_pool_settings is the base defaults
  #   local.staging_default_gke_node_pool_settings overrides previous values, but only if var.environment == "staging"
  #   local.prod_default_gke_node_pool_settings overrides previous values, but only if var.environment == "prod"
  #   var.custom_core_node_pool_settings overrides all for anything that is set

  # Default settings
  #   - Autoscaling, 0-1 nodes
  #   - n1-standard-2 machine type
  #   - 100GB disk size
  #   - Non-preemptible nodes
  #   - Initial size of 1
  default_gke_node_pool_settings = {
    autoscaling_max_size = 10
    autoscaling_min_size = 1
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 1
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  # Default staging settings
  #   - Autoscaling, 0-1 nodes
  #   - n1-standard-4 machine type
  #   - 100GB disk size
  #   - Non-preemptible nodes
  #   - Initial size of 1
  staging_default_gke_node_pool_settings = {
    autoscaling_max_size = 1
    autoscaling_min_size = 0
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 1
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  # Default prod settings
  #   - Autoscaling, 0-1 nodes
  #   - custom machine type
  #   - 100GB disk size
  #   - Non-preemptible nodes
  #   - Initial size of 1
  prod_default_gke_node_pool_settings = {
    autoscaling_max_size = 1
    autoscaling_min_size = 1
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 0
    machine_type         = null
    memory_size_mb       = 10 * 1024
    num_cpus             = 8
    preemptible          = true
  }

  etl_highmem_default_gke_node_pool_settings = {
    autoscaling_max_size = 3
    autoscaling_min_size = 0
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 0
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  etl_highmem_staging_gke_node_pool_settings = {
    autoscaling_max_size = 15
    autoscaling_min_size = 0
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 0
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  etl_highmem_prod_gke_node_pool_settings = {
    autoscaling_max_size = 10
    autoscaling_min_size = 0
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 0
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  etl_backfill_default_gke_node_pool_settings = {
    autoscaling_max_size = 150
    autoscaling_min_size = 0
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 0
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  etl_backfill_staging_gke_node_pool_settings = {
    autoscaling_max_size = 90
    autoscaling_min_size = 0
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 0
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  etl_backfill_prod_gke_node_pool_settings = {
    autoscaling_max_size = 40
    autoscaling_min_size = 0
    disk_type            = "STANDARD"
    disk_size_gb         = 100
    initial_node_count   = 0
    machine_type         = "n1-standard-2"
    memory_size_mb       = null
    num_cpus             = null
    preemptible          = true
  }

  gke_node_pool_settings = merge(
    local.default_gke_node_pool_settings,
    # var.environment == "staging" ? local.staging_default_gke_node_pool_settings : {},
    # var.environment == "prod" ? local.prod_default_gke_node_pool_settings : {},
    # var.custom_core_node_pool_settings
  )

  gke_highmem_node_pool_settings = merge(
    local.etl_highmem_default_gke_node_pool_settings,
    # var.environment == "staging" ? local.etl_highmem_staging_gke_node_pool_settings : {},
    # var.environment == "prod" ? local.etl_highmem_prod_gke_node_pool_settings : {},
    # var.custom_highmem_node_pool_settings
  )

  gke_backfill_node_pool_settings = merge(
    local.etl_backfill_default_gke_node_pool_settings,
    # var.environment == "staging" ? local.etl_backfill_staging_gke_node_pool_settings : {},
    # var.environment == "prod" ? local.etl_backfill_prod_gke_node_pool_settings : {},
    # var.custom_backfill_node_pool_settings
  )

  //  # `machine_type` is only set if custom settings are not provided
  //  gke_machine_type = local.gke_node_pool_settings.memory_size_mb == null || local.gke_node_pool_settings.num_cpus == null ? local.gke_node_pool_settings.machine_type : null
  //
  //  # `memory_size_mb` and `num_cpus` are only set if both custom settings are provided
  //  gke_memory_size_mb = local.gke_node_pool_settings.memory_size_mb != null && local.gke_node_pool_settings.num_cpus != null ? local.gke_node_pool_settings.memory_size_mb : null
  //  gke_num_cpus       = local.gke_node_pool_settings.memory_size_mb != null && local.gke_node_pool_settings.num_cpus != null ? local.gke_node_pool_settings.num_cpus : null

  # LABELS/TAGS
  default_labels = {
    client      = local.client
    client_iata = local.client_iata
    deployment  = "airflow"
    flyr_owner  = "jacek_dot_dolega"
    flyr_team   = "dp"
  }

  # Have custom labels be overwritten by predefined labels
  labels = merge(
    { for key, value in local.default_labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) if value != null },
    # { for key, value in var.custom_labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) },
  )

  gke_node_pool_labels = merge(
    { for key, value in local.labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) if value != null },
    # { for key, value in var.custom_gke_node_pool_labels : lower(replace(key, " ", "-")) => lower(replace(value, " ", "-")) },
  )

  core_node_pool_labels    = merge(local.gke_node_pool_labels, { core : true })
  etl_highmem_pool_labels  = merge(local.gke_node_pool_labels, { highmem-pool : true })
  etl_backfill_pool_labels = merge(local.gke_node_pool_labels, { etlpool : true })

  cluster_admin_role_name        = "cluster-admin-role"
  admin_role_name                = "admin-role"
  developer_role_name            = "developer-role"
  prod_viewer_role_name          = "prod-viewer-role"
  airflow_namespace_removal_name = "airflow-namespace-removal-role"

  # ETL Secrets

  # airflow_secrets = {
  #   AIRFLOW__CORE__SQL_ALCHEMY_CONN = null # AIRFLOW__CORE__SQL_ALCHEMY_CONN
  #   ETL_SLACK_TOKEN                 = null # ETL_SLACK_TOKEN|DEV_ETL_SLACK_TOKEN|PROD_ETL_SLACK_TOKEN|STAGING_ETL_SLACK_TOKEN

  #   SFTP_PASSWORD                                                                            = null # <CLIENT_IATA>_SFTP_PASSWORD
  #   TIMESCALE_USER                                                                           = null # TIMESCALE_USER
  #   TIMESCALE_PASSWORD                                                                       = null # TIMESCALE_PASSWORD
  #   DATA_MAIL_LOGIN                                                                          = null # DATA_MAIL_LOGIN
  #   DATA_MAIL_PASSWORD                                                                       = null # DATA_MAIL_PASSWORD
  #   CONFLUENCE_UID                                                                           = null # CONFLUENCE_UID
  #   CONFLUENCE_TOKEN                                                                         = null # CONFLUENCE_TOKEN
  #   "airflow-secrets__DATA_MAIL_LOGIN"                                                       = null # DATA_MAIL_LOGIN
  #   "airflow-secrets__DATA_MAIL_PASSWORD"                                                    = null # DATA_MAIL_PASSWORD
  #   "airflow-secrets__CONFLUENCE_UID"                                                        = null # CONFLUENCE_UID
  #   "airflow-secrets__CONFLUENCE_TOKEN"                                                      = null # CONFLUENCE_TOKEN
  #   "airflow-secrets__AIRFLOW__CORE__SQL_ALCHEMY_CONN"                                       = null # AIRFLOW__CORE__SQL_ALCHEMY_CONN
  #   "airflow-secrets__ETL_SLACK_TOKEN"                                                       = null # ETL_SLACK_TOKEN
  #   "airflow-secrets__${upper(var.environment)}_ETL_SLACK_TOKEN"                           = null # <ENV>_ETL_SLACK_TOKEN
  #   "airflow-secrets__${upper(var.environment)}_${upper(local.client_iata)}_SFTP_PASSWORD" = null # <ENV>_<CLIENT_IATA>_SFTP_PASSWORD
  #   "airflow-secrets__${upper(local.client_iata)}_SFTP_PASSWORD"                             = null # <CLIENT_IATA>_SFTP_PASSWORD
  #   "airflow-secrets__TIMESCALE_USER"                                                        = null # TIMESCALE_USER
  #   "airflow-secrets__TIMESCALE_PASSWORD"                                                    = null # TIMESCALE_PASSWORD
  # }

  # environment_specific_secrets = {
  #   dev = {
  #     POSTGRES_USER                            = null # POSTGRES_USER
  #     POSTGRES_PASSWORD                        = null # POSTGRES_PASSWORD
  #     "airflow-env-secrets__POSTGRES_USER"     = null # POSTGRES_USER
  #     "airflow-env-secrets__POSTGRES_PASSWORD" = null # POSTGRES_PASSWORD
  #     "airflow-postgresql__postgres-password"  = null # postgres-password
  #   }
  #   staging = {
  #     SQL_USERNAME                        = null # SQL_USERNAME
  #     SQL_PASSWORD                        = null # SQL_PASSWORD
  #     "airflow-env-secrets__SQL_USERNAME" = null # SQL_USERNAME
  #     "airflow-env-secrets__SQL_PASSWORD" = null # SQL_PASSWORD
  #   }
  #   int = {
  #     SQL_USERNAME                        = null # SQL_USERNAME
  #     SQL_PASSWORD                        = null # SQL_PASSWORD
  #     "airflow-env-secrets__SQL_USERNAME" = null # SQL_USERNAME
  #     "airflow-env-secrets__SQL_PASSWORD" = null # SQL_PASSWORD
  #   }
  #   prod = {
  #     ETL_PAGERDUTY_KEY                                 = null # ETL_PAGERDUTY_KEY
  #     PAGERDUTY_RAW_DATA_SLA_KEY                        = null # PAGERDUTY_RAW_DATA_SLA_KEY
  #     "airflow-env-secrets__ETL_PAGERDUTY_KEY"          = null # ETL_PAGERDUTY_KEY
  #     "airflow-env-secrets__PAGERDUTY_RAW_DATA_SLA_KEY" = null # PAGERDUTY_RAW_DATA_SLA_KEY
  #   }
  # }


  # client_specific_secrets = {
  #   b6 = {
  #     "B6_KAFKA_BROKER_CONFIG_${upper(var.environment)}"                  = null # B6_KAFKA_BROKER_CONFIG_<ENV>
  #     "airflow-secrets__B6_KAFKA_BROKER_CONFIG_${upper(var.environment)}" = null # B6_KAFKA_BROKER_CONFIG_<ENV>
  #     "${upper(var.environment)}_SOLVER_SLACK_TOKEN"                      = null # <ENV>_SOLVER_SLACK_TOKEN
  #     "airflow-secrets__${upper(var.environment)}_SOLVER_SLACK_TOKEN"     = null # <ENV>_SOLVER_SLACK_TOKEN
  #     "${upper(var.environment)}_B6_ELASTIC_PASSWORD"                     = null # <ENV>_B6_ELASTIC_PASSWORD
  #     "airflow-secrets__${upper(var.environment)}_B6_ELASTIC_PASSWORD"    = null # <ENV>_B6_ELASTIC_PASSWORD
  #     "${upper(var.environment)}_SLACK_TOKEN"                             = null # <ENV>_SLACK_TOKEN
  #     "airflow-secrets__${upper(var.environment)}_SLACK_TOKEN"            = null # <ENV>_SLACK_TOKEN
  #     AVP_SLACK_TOKEN                                                       = null # AVP_SLACK_TOKEN
  #     "airflow-secrets__AVP_SLACK_TOKEN"                                    = null # AVP_SLACK_TOKEN
  #     "${upper(var.environment)}_B6_AUTH0_CLIENT_SECRET"                  = null # <ENV>_B6_AUTH0_CLIENT_SECRET
  #     "airflow-secrets__${upper(var.environment)}_B6_AUTH0_CLIENT_SECRET" = null # <ENV>_B6_AUTH0_CLIENT_SECRET
  #   }
  #   ey = {
  #     DATA_INGEST_SA_JSON                    = null # DATA_INGEST_SA_JSON
  #     "airflow-secrets__DATA_INGEST_SA_JSON" = null # DATA_INGEST_SA_JSON
  #   }
  #   jq = {
  #     DATA_INGEST_SA_JSON                    = null # DATA_INGEST_SA_JSON
  #     "airflow-secrets__DATA_INGEST_SA_JSON" = null # DATA_INGEST_SA_JSON
  #   }
  #   la = {
  #     DATA_INGEST_SA_JSON                         = null # DATA_INGEST_SA_JSON
  #     "airflow-secrets__DATA_INGEST_SA_JSON"      = null # DATA_INGEST_SA_JSON
  #     DATA_INTEGRATION_SA_JSON                    = null # DATA_INTEGRATION_SA_JSON
  #     "airflow-secrets__DATA_INTEGRATION_SA_JSON" = null # DATA_INTEGRATION_SA_JSON
  #     DATA_PROD_SA_JSON                           = null # DATA_PROD_SA_JSON
  #     "airflow-secrets__DATA_PROD_SA_JSON"        = null # DATA_PROD_SA_JSON
  #   }
  #   nz = {
  #     CONNECT_SASL_JAAS_CONFIG                                    = null # CONNECT_SASL_JAAS_CONFIG|CONNECT_CONSUMER_SASL_JAAS_CONFIG|CONNECT_PRODUCER_SASL_JAAS_CONFIG
  #     KAFKA_PROXY_USERNAME                                        = null # ETL_KAFKA_PROXY_USERNAME|KAFKA_REST_AUTHENTICATION_ROLES
  #     KAFKA_PROXY_PASSWORD                                        = null # ETL_KAFKA_PROXY_PASSWORD
  #     KAFKA_CLUSTER_SECRET                                        = null # ETL_KAFKA_CLUSTER_SECRET
  #     KAFKA_CLUSTER_KEY                                           = null # ETL_KAFKA_CLUSTER_KEY
  #     AWS_S3_BUCKET_KEY_ID                                        = null # AWS_S3_BUCKET_KEY_ID
  #     AWS_S3_BUCKET_SECRET_KEY                                    = null # AWS_S3_BUCKET_SECRET_KEY
  #     "kafka-connect-secret__CONNECT_SASL_JAAS_CONFIG"            = null # CONNECT_SASL_JAAS_CONFIG
  #     "kafka-connect-secret__CONNECT_CONSUMER_SASL_JAAS_CONFIG"   = null # CONNECT_CONSUMER_SASL_JAAS_CONFIG
  #     "kafka-connect-secret__CONNECT_PRODUCER_SASL_JAAS_CONFIG"   = null # CONNECT_PRODUCER_SASL_JAAS_CONFIG
  #     "kafka-connect-secret__TIMESCALE_USER"                      = null # TIMESCALE_USER
  #     "kafka-connect-secret__TIMESCALE_PASSWORD"                  = null # TIMESCALE_PASSWORD
  #     "kafka-rest-proxy-secrets__KAFKA_REST_AUTHENTICATION_ROLES" = null # KAFKA_REST_AUTHENTICATION_ROLES
  #     "airflow-env-secrets__ETL_KAFKA_CLUSTER_KEY"                = null # ETL_KAFKA_CLUSTER_KEY
  #     "airflow-env-secrets__ETL_KAFKA_CLUSTER_SECRET"             = null # ETL_KAFKA_CLUSTER_SECRET
  #     "airflow-env-secrets__ETL_KAFKA_PROXY_USERNAME"             = null # ETL_KAFKA_PROXY_USERNAME
  #     "airflow-env-secrets__ETL_KAFKA_PROXY_PASSWORD"             = null # ETL_KAFKA_PROXY_PASSWORD
  #   }
  #   lo = {
  #     DATA_INGEST_SA_JSON                    = null # DATA_INGEST_SA_JSON
  #     "airflow-secrets__DATA_INGEST_SA_JSON" = null # DATA_INGEST_SA_JSON
  #   }
  # }

  # client_env_specific_secrets = {
  #   b6 = {
  #     dev = {
  #       B6_KAFKA_BROKER_CONFIG_STAGING                    = null # B6_KAFKA_BROKER_CONFIG_STAGING
  #       "airflow-secrets__B6_KAFKA_BROKER_CONFIG_STAGING" = null # B6_KAFKA_BROKER_CONFIG_STAGING
  #     }
  #     staging = {
  #       B6_KAFKA_BROKER_CONFIG_DEV                    = null # B6_KAFKA_BROKER_CONFIG_DEV
  #       "airflow-secrets__B6_KAFKA_BROKER_CONFIG_DEV" = null # B6_KAFKA_BROKER_CONFIG_DEV
  #     }
  #     prod = {
  #       B6_KAFKA_BROKER_CONFIG_INTEGRATION                          = null # B6_KAFKA_BROKER_CONFIG_INTEGRATION
  #       "airflow-secrets__B6_KAFKA_BROKER_CONFIG_INTEGRATION"       = null # B6_KAFKA_BROKER_CONFIG_INTEGRATION
  #       PROD_B6_INTEG_ELASTIC_PASSWORD                              = null # PROD_B6_INTEG_ELASTIC_PASSWORD
  #       "airflow-secrets__PROD_B6_INTEG_ELASTIC_PASSWORD"           = null # PROD_B6_INTEG_ELASTIC_PASSWORD
  #       PROD_B6_INTEG_AUTH0_CLIENT_SECRET                           = null # PROD_B6_INTEG_AUTH0_CLIENT_SECRET
  #       "airflow-secrets__PROD_B6_INTEG_AUTH0_CLIENT_SECRET"        = null # PROD_B6_INTEG_AUTH0_CLIENT_SECRET
  #       PROD_B6_SOLVER_PAGERDUTY_INTEGRATION_KEY                    = null # PROD_B6_SOLVER_PAGERDUTY_INTEGRATION_KEY
  #       "airflow-secrets__PROD_B6_SOLVER_PAGERDUTY_INTEGRATION_KEY" = null # PROD_B6_SOLVER_PAGERDUTY_INTEGRATION_KEY
  #     }
  #   }
  #   nz = {
  #     dev = {
  #       KAFKA_HTTP_BASIC_AUTH                                            = null # HTTP_BASIC_AUTH
  #       "kafka-rest-proxy-secrets-mounted__HTTP_BASIC_AUTH"              = null # HTTP_BASIC_AUTH
  #       KAFKA_SERVER_CONFIG                                              = null # KAFKA_SERVER_CONFIG
  #       "kafka-rest-proxy-secrets-mounted__KAFKA_SERVER_CONFIG"          = null # KAFKA_SERVER_CONFIG
  #       KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG                             = null # KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG
  #       "kafka-rest-proxy-secrets__KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG" = null # KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG
  #       KAFKA_REST_CLIENT_SASL_JAAS_CONFIG                               = null # KAFKA_REST_CLIENT_SASL_JAAS_CONFIG
  #       "kafka-rest-proxy-secrets__KAFKA_REST_CLIENT_SASL_JAAS_CONFIG"   = null # KAFKA_REST_CLIENT_SASL_JAAS_CONFIG
  #     }
  #     prod = {
  #       KAFKA_HTTP_BASIC_AUTH                                            = null # HTTP_BASIC_AUTH
  #       "kafka-rest-proxy-secrets-mounted__HTTP_BASIC_AUTH"              = null # HTTP_BASIC_AUTH
  #       KAFKA_SERVER_CONFIG                                              = null # KAFKA_SERVER_CONFIG
  #       "kafka-rest-proxy-secrets-mounted__KAFKA_SERVER_CONFIG"          = null # KAFKA_SERVER_CONFIG
  #       KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG                             = null # KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG
  #       "kafka-rest-proxy-secrets__KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG" = null # KAFKA_REST_CONSUMER_SASL_JAAS_CONFIG
  #       KAFKA_REST_CLIENT_SASL_JAAS_CONFIG                               = null # KAFKA_REST_CLIENT_SASL_JAAS_CONFIG
  #       "kafka-rest-proxy-secrets__KAFKA_REST_CLIENT_SASL_JAAS_CONFIG"   = null # KAFKA_REST_CLIENT_SASL_JAAS_CONFIG
  #     }
  #   }
  # }

  # secrets = merge(
  #   local.airflow_secrets,
  #   var.environment_specific_secrets[var.environment],
  #   lookup(local.client_specific_secrets, local.client_iata_lower, {}),
  #   lookup(lookup(local.client_env_specific_secrets, local.client_iata_lower, {}), var.environment, {}),
  # )

  env = {
    development   = "dev"
    nonproduction = "stg"
    nonproduction = "int"
    production    = "prd"
  }[var.environment]

  # default_cloudsql_database_flags = {
  #   max_connections    = 4096,
  #   temp_file_limit    = 2147483647,
  #   max_wal_size       = 2147483647,
  #   checkpoint_timeout = 7200,
  #   autovacuum         = "on"
  #   work_mem           = 102400,
  # }

  # default_cloudsql_settings = {
  #   disk_autoresize       = true
  #   disk_autoresize_limit = 300
  #   disk_size_gb          = null
  #   disk_type             = "SSD"
  #   num_cpus              = 4
  #   memory_size_mb        = 16 * 1024
  #   high_availability     = false
  #   maintenance_window    = null

  #   # 7AM UTC, Midnight PDT
  #   utc_backup_window_start_time = "7:00"
  # }

  # prod_default_cloudsql_settings = {
  #   disk_autoresize       = true
  #   disk_autoresize_limit = 300
  #   disk_size_gb          = null
  #   disk_type             = "SSD"
  #   num_cpus              = 4
  #   memory_size_mb        = 16 * 1024
  #   high_availability     = true
  # }

  # cloudsql_database_flags = merge(
  #   local.default_cloudsql_database_flags,
  #   var.custom_cloudsql_database_flags
  # )

  # cloudsql_settings = merge(
  #   local.default_cloudsql_settings,
  #   var.environment == "prod" ? local.prod_default_cloudsql_settings : {},
  #   var.custom_cloudsql_settings
  # )
  env_short = {
    "development"   = "dev",
    "nonproduction" = "stg",
    "production"    = "prd"
  }
  env_code = substr(var.environment, 0, 1)
}

module "region_naming" {
  source  = "terraform-google-modules/utils/google"
  version = "~> 0.7"
}

module "naming" {
  source      = "app.terraform.io/flyrlabs/modules/flyr//modules/naming"
  version     = "0.8.0"
  environment = local.env_short[var.environment]
  region      = var.region
  instance    = var.instance_number
  name        = var.stack
  product     = var.stack
  stack       = var.stack
  tenant      = var.tenant
  owner       = "james_nguyen"
}

module "etl_gke_cluster" {
  source  = "../../../modules/io/gke-cluster-v2"
  disable = false # !var.enable_gke

  name       = "${var.environment}-etl-cluster"
  project_id = var.project_id
  region     = local.region
  zone       = local.zone

  vpc_network_self_link         = data.terraform_remote_state.google_region.outputs.network_self_link
  vpc_subnetwork_self_link      = data.terraform_remote_state.google_region.outputs.network_subnets["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].self_link
  cluster_secondary_range_name  = data.terraform_remote_state.google_region.outputs.network_subnets["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].secondary_ip_range[0].range_name
  services_secondary_range_name = data.terraform_remote_state.google_region.outputs.network_subnets["${var.region}/sb-${local.env_code}-${var.project_id}-${module.region_naming.region_short_name_map[var.region]}-${var.instance_number}"].secondary_ip_range[1].range_name
  master_ipv4_cidr_block        = data.terraform_remote_state.google_region.outputs.network_master_ipv4_cidr_block # var.master_ipv4_cidr_block
  master_global_access_enabled  = false
  use_shared_network            = true
  enable_private_nodes          = true
  enable_private_endpoint       = false
  # gke_usage_metering_dataset_id = var.gke_usage_metering_dataset_id
  enable_legacy_abac        = false # var.enable_legacy_abac
  workload_identity_enabled = false # var.workload_identity_enabled

  # maintenance_recurring_window = var.gke_maintenance_recurring_window

  environment = var.environment
  owner       = local.owner
  team        = local.team

  # notification_config_topic = module.gke_upgrade_notification_topic.id

  custom_labels = local.labels
  # depends_on = [
  #   google_compute_subnetwork_iam_member.gke_shared_vpc_subnets,
  #   google_project_iam_member.compute_host_agent,
  #   google_project_iam_member.gke_host_agent["roles/compute.securityAdmin"],
  #   google_project_iam_member.gke_host_agent["roles/container.serviceAgent"],
  # ]
}

module "core_node_pool" {
  source  = "../../../modules/io/gke-node-pool"
  disable = false # !var.enable_gke

  name       = "core-node-pool"
  project_id = var.project_id

  gke_cluster_name     = module.etl_gke_cluster.name
  gke_cluster_location = module.etl_gke_cluster.location

  service_account = "324744733732-compute@developer.gserviceaccount.com"

  autoscaling_max_size = local.gke_node_pool_settings.autoscaling_max_size
  autoscaling_min_size = local.gke_node_pool_settings.autoscaling_min_size
  disk_type            = local.gke_node_pool_settings.disk_type
  disk_size_gb         = local.gke_node_pool_settings.disk_size_gb
  initial_node_count   = local.gke_node_pool_settings.initial_node_count
  machine_type         = local.gke_node_pool_settings.machine_type
  memory_size_mb       = local.gke_node_pool_settings.memory_size_mb
  num_cpus             = local.gke_node_pool_settings.num_cpus
  preemptible          = local.gke_node_pool_settings.preemptible
  image_type           = "COS_CONTAINERD"

  environment = var.environment
  owner       = local.owner
  team        = local.team

  custom_labels = local.core_node_pool_labels
}

module "highmem_node_pool" {
  source  = "../../../modules/io/gke-node-pool"
  disable = false # !var.enable_gke

  name       = "etl-highmem-node-pool"
  project_id = var.project_id

  gke_cluster_name     = module.etl_gke_cluster.name
  gke_cluster_location = module.etl_gke_cluster.location

  service_account = "324744733732-compute@developer.gserviceaccount.com"

  autoscaling_max_size = local.gke_highmem_node_pool_settings.autoscaling_max_size
  autoscaling_min_size = local.gke_highmem_node_pool_settings.autoscaling_min_size
  disk_type            = local.gke_highmem_node_pool_settings.disk_type
  disk_size_gb         = local.gke_highmem_node_pool_settings.disk_size_gb
  initial_node_count   = local.gke_highmem_node_pool_settings.initial_node_count
  machine_type         = local.gke_highmem_node_pool_settings.machine_type
  memory_size_mb       = local.gke_highmem_node_pool_settings.memory_size_mb
  num_cpus             = local.gke_highmem_node_pool_settings.num_cpus
  preemptible          = local.gke_highmem_node_pool_settings.preemptible
  image_type           = "COS_CONTAINERD"

  environment = var.environment
  owner       = local.owner
  team        = local.team

  custom_labels = local.etl_highmem_pool_labels
  depends_on    = [module.core_node_pool]
}

module "backfill_node_pool" {
  source  = "../../../modules/io/gke-node-pool"
  disable = false # !var.enable_gke

  name       = "etl-backfill-node-pool"
  project_id = var.project_id

  gke_cluster_name     = module.etl_gke_cluster.name
  gke_cluster_location = module.etl_gke_cluster.location

  service_account = "324744733732-compute@developer.gserviceaccount.com"

  autoscaling_max_size = local.gke_backfill_node_pool_settings.autoscaling_max_size
  autoscaling_min_size = local.gke_backfill_node_pool_settings.autoscaling_min_size
  disk_type            = local.gke_backfill_node_pool_settings.disk_type
  disk_size_gb         = local.gke_backfill_node_pool_settings.disk_size_gb
  initial_node_count   = local.gke_backfill_node_pool_settings.initial_node_count
  machine_type         = local.gke_backfill_node_pool_settings.machine_type
  memory_size_mb       = local.gke_backfill_node_pool_settings.memory_size_mb
  num_cpus             = local.gke_backfill_node_pool_settings.num_cpus
  preemptible          = local.gke_backfill_node_pool_settings.preemptible
  image_type           = "COS_CONTAINERD"

  environment = var.environment
  owner       = local.owner
  team        = local.team

  custom_labels = local.etl_backfill_pool_labels
  taints        = [{ effect = "NO_SCHEDULE", key = "etlpool", value = "true" }]
  depends_on    = [module.core_node_pool]
}

module "application_platform_node_pool" {
  source  = "../../../modules/io/gke-node-pool"
  disable = true # !var.enable_gke || var.workload_identity_enabled == false

  name       = "platform-node-pool"
  project_id = var.project_id

  gke_cluster_name     = module.etl_gke_cluster.name
  gke_cluster_location = module.etl_gke_cluster.location

  service_account = "324744733732-compute@developer.gserviceaccount.com"

  autoscaling_max_size      = 10
  autoscaling_min_size      = 0
  disk_type                 = "balanced"
  disk_size_gb              = 60
  image_type                = "COS_CONTAINERD"
  initial_node_count        = 0
  machine_type              = "n2d-standard-2"
  preemptible               = false
  workload_identity_enabled = true

  environment = var.environment
  owner       = local.owner
  team        = local.team

  taints = [
    { effect = "NO_SCHEDULE", key = "team", value = "platform" }
  ]
  custom_labels = { "team" : "platform" }
}










# module "etl_argocd_bootstrap_sa" {
#   source  = "../../resources/argocd-bootstrap/serviceaccount"
#   disable = !var.enable_gke || var.argocd_exclude

#   project_id = var.project_id

#   providers = {
#     kubernetes = kubernetes.etl_gke
#   }
# }

# module "etl_argocd_bootstrap_secret" {
#   source  = "../../resources/argocd-bootstrap/cluster-secret"
#   disable = !var.enable_gke || var.argocd_exclude

#   project_id   = var.project_id
#   client_iata  = local.client_iata
#   environment  = local.environment
#   purpose      = "etl"
#   host         = module.etl_gke_cluster.gke_auth.host
#   argocd_sa_ca = module.etl_gke_cluster.gke_auth.cluster_ca

#   providers = {
#     kubernetes = kubernetes.argocd_cluster
#   }
# }

# module "etl_argocd_bootstrap_secret_dev" {
#   source  = "../../resources/argocd-bootstrap/cluster-secret"
#   disable = !var.enable_gke || var.argocd_exclude_dev

#   project_id   = var.project_id
#   namespace    = "argocd-dev"
#   client_iata  = local.client_iata
#   environment  = local.environment
#   purpose      = "etl"
#   host         = module.etl_gke_cluster.gke_auth.host
#   argocd_sa_ca = module.etl_gke_cluster.gke_auth.cluster_ca

#   providers = {
#     kubernetes = kubernetes.argocd_cluster
#   }
# }

# module "etl_argocd_bootstrap_secret_prod" {
#   source  = "../../resources/argocd-bootstrap/cluster-secret"
#   disable = !var.enable_gke || !contains(["nz", "b6", "fl", "vs", "av"], local.client_iata_lower)

#   project_id   = var.project_id
#   namespace    = "argocd-prod"
#   client_iata  = local.client_iata
#   environment  = local.environment
#   purpose      = "etl"
#   host         = module.etl_gke_cluster.gke_auth.host
#   argocd_sa_ca = module.etl_gke_cluster.gke_auth.cluster_ca

#   providers = {
#     kubernetes = kubernetes.argocd_cluster
#   }
# }
