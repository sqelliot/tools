#!/bin/bash

for package in `cat ./apt`; do
  echo
  echo "installing <${package}>"
  yes | sudo apt install $package
done
