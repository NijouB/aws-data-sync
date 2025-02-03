terraform {
  backend "s3" {
    bucket  = "my-precious-bucket"
    key     = "terraform/aws/datasync.tfstate"
    region  = "us-east-1"
    profile = "admin"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = var.destination_account_profile

  assume_role {
    role_arn = "arn:aws:iam::${var.destination_account}:role/${var.destination_account_role}"
  }
}

provider "aws" {
  alias   = "source_account"
  region  = "us-east-1"
  profile = var.source_account_profile
  assume_role {
    role_arn = "arn:aws:iam::${var.source_account}:role/${var.source_account_role}"
  }
}

provider "aws" {
  alias   = "destination_account"
  region  = "us-east-1"
  profile = var.destination_account_profile

  assume_role {
    role_arn = "arn:aws:iam::${var.destination_account}:role/${var.destination_account_role}"
  }
}
