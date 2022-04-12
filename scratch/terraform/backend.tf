terraform {
  backend "remote" {
    hostname     = "ptfe.prod.dht.live"
    organization = "resmed"
    workspaces {
      #name = "rmd-app-mcs-iomt-data-streaming-dev-resources"
      name = "rmd-app-mcs-dev-echo"
      #name = "rmd-app-mcs-iomt-data-streaming-dev-2-resources"
      #name = "rmd-app-mcs-iomt-data-streaming-dev-3-resources"
      #name = "rmd-app-mcs-iomt-data-streaming-dev-4-resources"
    }
  }
}
