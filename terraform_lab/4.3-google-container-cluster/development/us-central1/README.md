# google-container-cluster

## Investigate

```
  # module.vpc_subnet[0].google_compute_subnetwork.subnetwork["us-central1/sb-d-prj-lab-james-nguyen-usc1-22"] will be updated in-place
  ~ resource "google_compute_subnetwork" "subnetwork" {
        id                         = "projects/prj-lab-james-nguyen/regions/us-central1/subnetworks/sb-d-prj-lab-james-nguyen-usc1-22"
        name                       = "sb-d-prj-lab-james-nguyen-usc1-22"
      ~ private_ip_google_access   = true -> false
        # (12 unchanged attributes hidden)
    }
```
