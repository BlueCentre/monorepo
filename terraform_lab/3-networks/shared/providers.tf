/******************************************
  Provider request timeout configuration
 *****************************************/
 
provider "google" {
  request_timeout = "5m"
}

provider "google-beta" {
  request_timeout = "5m"
}
