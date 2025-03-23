# Configuration for the CloudNativePG operator
# See https://github.com/cloudnative-pg/cloudnative-pg/blob/main/charts/cloudnative-pg/values.yaml for reference

mode: standalone

cluster:
  instances: 1

backups:
  enabled: false
