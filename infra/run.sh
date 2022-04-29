#! /bin/bash

export CONFIG="$(cat config.json | jq -r .)"

export SUBSCRIPTION_ID="$(echo $CONFIG | jq -r '.subscription_id')"
export TENANT_ID="$(echo $CONFIG | jq -r '.tenant_id')"

export ARM_DEPLOYMENT_NAME="$(echo $CONFIG | jq -r '.arm_deployment_name')"
export ADMIN_EMAIL_ADDRESS="$(echo $CONFIG | jq -r '.admin_email_address')"
export PREFIX="$(echo $CONFIG | jq -r '.rgNamePrefix')"
export LOCATION="$(echo $CONFIG | jq -r '.location')"

az account set --subscription $SUBSCRIPTION_ID

# Will take 30-60 mintues to deploy due to APIM 
az deployment sub create \
	--name $ARM_DEPLOYMENT_NAME \
	--template-file ./bicep/deployment.bicep \
	--location=$LOCATION \
	--parameters prefix=$PREFIX \
	--parameters admin_email_address=$ADMIN_EMAIL_ADDRESS \
	--parameters location=$LOCATION \
	--no-wait