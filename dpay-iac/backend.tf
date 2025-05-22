terraform {
  backend "s3" {
    bucket = "explore-adhoc"
    key    = "adhoc/statefile.tfstate"
    region = "ap-southeast-3"
  }
}
