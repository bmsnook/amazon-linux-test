terraform {
  cloud {
    organization = "fixitdad"

    workspaces {
      name = "aws-altest"
    }
  }
}
