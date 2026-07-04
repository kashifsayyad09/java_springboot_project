terraform {
  backend "s3" {
    bucket       = "qwertsdhewef"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
