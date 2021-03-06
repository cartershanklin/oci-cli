#!/usr/bin/env bash
# Copyright (c) 2016, 2018, Oracle and/or its affiliates. All rights reserved.
# This script provides an example of how use the instance pools CLI in terms of:
#   - Creating an instance configuration
#   - Launch from that instance configuration
#   - Deleting instance configuration
#
# For more help with specific instance pool commands with, see:
#   oci compute-management instance-configuration -h
#
# Requirements for running this script:
#   - OCI CLI v2.4.33 or later (you can check this by running oci --version)
#   - jq (https://stedolan.github.io/jq/) for JSON querying and manipulation of CLI output. This may be a useful utility in general
#     and may help cater to scenarios which can't be wholly addressed by the --query option in the CLI

set -e 

COMPARTMENT_ID=""  # Your compartment OCID
AD="" # the AD where the pool will be spun up (the pool in this example only spans a single AD)
SUBNET_ID="" # the subnet ocid in the AD above
IMAGE_ID="" # the image ID to use for instances

INSTANCE_DETAILS_FILE_LOCATION="./instance_configs_example/instance_details_template.json"
LAUNCH_DETAILS_FILE_LOCATION="./instance_configs_example/launch_details_template.json"

INSTANCE_DETAILS=$(sed s/__COMPARTMENT_ID__/$COMPARTMENT_ID/g $INSTANCE_DETAILS_FILE_LOCATION | sed s/__IMAGE_ID__/$IMAGE_ID/g)
echo "instance details"
echo $INSTANCE_DETAILS

LAUNCH_DETAILS=$(sed s/__AD__/$AD/g $LAUNCH_DETAILS_FILE_LOCATION | sed s/__SUBNET_ID__/$SUBNET_ID/g)
echo "launch details"
echo $LAUNCH_DETAILS

INSTANCE_CONFIG_ID=""
INSTANCE_ID=""

echo "Creating instance config in compartment $COMPARTMENT_ID with launch details from $INSTANCE_DETAILS_FILE_LOCATION"
INSTANCE_CONFIG_ID=$(oci compute-management instance-configuration create --instance-details "$INSTANCE_DETAILS" --compartment-id $COMPARTMENT_ID --query 'data.id' --raw-output)
echo "Created instance config with id $INSTANCE_CONFIG_ID"

# this demonstrates how to get the details of a created instance config
echo "Getting instance config details for id $INSTANCE_CONFIG_ID"
oci compute-management instance-configuration get --instance-configuration-id $INSTANCE_CONFIG_ID

echo "Launch from the created instance config by providing the missing parameters"
INSTANCE_ID=$(oci compute-management instance-configuration launch-compute-instance --instance-configuration-id $INSTANCE_CONFIG_ID --launch-details "$LAUNCH_DETAILS" --query 'data.id' --raw-output)
echo "Launched instance $INSTANCE_ID"

sleep 5s

echo "Deleting instance config $INSTANCE_CONFIG_ID"
oci compute-management instance-configuration delete --instance-configuration-id $INSTANCE_CONFIG_ID --force

echo "Deleting instance launched $INSTANCE_ID"
oci compute instance terminate --instance-id $INSTANCE_ID --force
