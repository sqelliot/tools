#!/bin/bash

source $HOME/repos/tools/bash/aws/.bashrc

fas_apps="fas-ods-simulator,fas-sqs,fas-apps-track,fas-apps-customxml,fas-apps-nontrackstanag,fas-apps-nerd-ingest,fas-topic-broker,fas-track-init,fas-nerd-init"
fas_inf="fas-kafka,fas-kafka-rest,fas-zookeeper,fas-ml"
cd ~/repos/fcms-deployment && ap plays/fas_one_button.yml -e build_no=-sean_elliott3 -e fas_version=99.99.T-SNAPSHOT -e deploy_types=${fas_apps} -e make_asg=no -e deploy_zone=a 
