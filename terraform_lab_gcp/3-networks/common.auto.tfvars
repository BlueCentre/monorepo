// The DNS name of peering managed zone. Must end with a period.
# domain = "example.com."

// Update the following line and add you email in the perimeter_additional_members list.
// You must be in this list to be able to view/access resources in the project protected by the VPC service controls.

# perimeter_additional_members = ["user:YOUR-USER-EMAIL@example.com"]

remote_state_bucket = "bkt-us-prj-b-seed-tfstate-dd4a"
