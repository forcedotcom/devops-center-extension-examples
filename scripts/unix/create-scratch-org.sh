#!/bin/bash


TRIAL_DAYS=30



if [ -z "$1" ]
then
  echo "Please specify a package version as the first argument"
  exit -1;
fi

APV=$1

if [ ! -z "$2" ]
then
  TRIAL_DAYS="$2"
  echo "Overriding TRIAL_DAYS to $TRIAL_DAYS"
fi

set -eo pipefail
sf org create scratch --definition-file config/project-scratch-def.json --set-default --no-ancestors --no-namespace --alias devops-ext --duration-days $TRIAL_DAYS

sf package install --package "$APV" --no-prompt --security-type AllUsers --wait 120

sf project deploy start

source ./scripts/unix/set-platform-event-user.sh

echo "Scratch Org Created"
