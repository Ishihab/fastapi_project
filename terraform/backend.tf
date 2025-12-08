terraform {
  backend "s3" {
    bucket       = "terraform-remotestate-dockyard43526"
    key          = "simple_social_remote_state/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}