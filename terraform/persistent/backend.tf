terraform {
  backend "s3" {
    bucket       = "kam-event-driven-url-shortener-tfstate"
    key          = "persistent/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}