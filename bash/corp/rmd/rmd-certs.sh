#!/bin/bash
 
set -euo pipefail
 
main() {
  local ca_cert_dir="/usr/local/share/ca-certificates"
 
  echo
  echo "Fetching Netskope root CA..."
  get_cert_chain "google.com" \
    | parse_root_cert \
    | sudo tee "${ca_cert_dir}/netskope.crt"
   
  echo
  echo "Fetching Resmed root CA..."
  get_cert_chain "confluence.ec2.local" \
    | parse_root_cert \
    | sudo tee "${ca_cert_dir}/resmed.crt"
   
  echo
  sudo update-ca-certificates
}
 
get_cert_chain() {
  local host=$1
   
  echo | openssl s_client \
    -showcerts \
    -servername "${host}" \
    -connect "${host}":443
}
 
parse_root_cert() {
  awk ' 
    # Look for adjacent lines where the certificate subject and issuer are the
    # same, and mark the location.
    # A cert subject and issuer being the same means the cert is self signed, and
    # thus a root cert.  Here is an example of the adjacent lines we are looking
    # for:
    #
    #   1 s:C = US, O = ResMed, OU = Certification Authorities, CN = ResMed Root CA1
    #     i:C = US, O = ResMed, OU = Certification Authorities, CN = ResMed Root CA1
    #
    match($0, /[[:digit:]] s:(.*)$/, matches) {
      subject = matches[1]
    }
 
    match($0, /\s+i:(.*)$/, matches) {
      issuer = matches[1]
    }
 
    # Print the entire PEM formatted certificate
    /-----BEGIN CERTIFICATE-----/, /-----END CERTIFICATE-----/ {
      if (subject == issuer) {
        print
      }
    }
  '
}
 
main
