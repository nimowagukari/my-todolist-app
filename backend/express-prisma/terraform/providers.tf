provider "aws" {
  default_tags {
    tags = {
      "ManagedBy" = "terraform"
    }
  }
}
