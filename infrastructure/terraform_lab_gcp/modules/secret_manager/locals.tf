locals {
  # distinct is needed to make the expanding function argument work
  iam = flatten([
    for secret, roles in var.iam : [
      for role, members in roles : {
        secret  = secret
        role    = role
        members = members
      }
    ]
  ])
  version_pairs = flatten([
    for secret, versions in var.versions : [
      for name, attrs in versions : merge(attrs, { name = name, secret = secret })
    ]
  ])
  version_keypairs = {
    for pair in local.version_pairs : "${pair.secret}:${pair.name}" => pair
  }
}
