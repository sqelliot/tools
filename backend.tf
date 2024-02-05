terraform {
 backend remote {
   organization = "resmed"
    hostname = "HOSTNAME"
    workspaces {
      name = "WORKSPACE_NAME"
  }
 }
}

