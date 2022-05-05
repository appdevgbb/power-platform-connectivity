# Power Platform Connectivity - Technical Demo

This directory will deploy the required Azure Infrastructure to simulate a Hybrid Network Connection.  This will allow you to:
- Deploy Two Virtual Networks
	- Network 1 "Hub"
		- Used as the hub/transitive network, hosted in Azure
		- This will host:
			- Azure APIM in a dedicated subnet for private network routing
			- A Backend API which APIM will resolve/route to
	- Network 2 "Onprem"
		- Used to simulate an on-premesis datacenter
		- This will host:
			- A second Backend API which APIM will resolve to
	- Connectivity between the two VNETs will be done via Azure Global VNET Peering
		- This is the quickest/easiest connectivity type
		- We use this to establish Layer 3 connectivity between the networks

## How to use

The following commands are initiated/started from the repo root directory

```bash
# Log into your Azure Account
az login --use-device-code

# List your available Azure Subscriptions and choose your desired/target subscription to deploy to 
az account list -o table

# change directory to the infra directory
cd infra

# Setup/Configure your config.json file
cp config.json.example config.json
# Modify the [subscription_id, tenant_id, admin_email_address] values

# Run the deployment script
bash run.sh
```

The deployment script will deploy all the necessary Azure Infrastrucutre and then deploy the container workloads which will be providing our API backends for APIM.