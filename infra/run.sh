#! /bin/bash

export CONFIG="$(cat config.json | jq -r .)"

export ARM_DEPLOYMENT_NAME="$(echo $CONFIG | jq -r '.arm_deployment_name')"
export ADMIN_EMAIL_ADDRESS="$(echo $CONFIG | jq -r '.admin_email_address')"
export PREFIX="$(echo $CONFIG | jq -r '.rgNamePrefix')"
export RG_LOCATION="$(echo $CONFIG | jq -r '.location')"
export RG_NAME=$PREFIX-$RG_LOCATION
export SUBSCRIPTION_ID="$(echo $CONFIG | jq -r '.subscription_id')"
export TENANT_ID="$(echo $CONFIG | jq -r '.tenant_id')"

az account set --subscription $SUBSCRIPTION_ID

az group create --name $RG_NAME --location $RG_LOCATION

# Will take 30-60 mintues to deploy due to APIM 
az deployment group create \
	--name $ARM_DEPLOYMENT_NAME \
	--mode Incremental \
	--resource-group $RG_NAME \
	--template-file ./bicep/deployment.bicep \
	--parameters prefix=$PREFIX \
	--parameters admin_email_address=$ADMIN_EMAIL_ADDRESS \
	--no-wait