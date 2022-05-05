// Naming convention requirements
param prefix string

param location string = resourceGroup().location

// Network Settings
param vnetPrefix string = '10.0.0.0/16'

param admin_email_address string

var localPrefix = '${prefix}-hub'

var workloadSubnet = {
  name: 'workloadsubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'       
  }
}

var loadBalancerSubnet = {
  name: 'loadbalancersubnet'
  properties: {
    addressPrefix: '10.0.2.0/24'
  }
}

//
// Top Level Resources
//

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${localPrefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: [
      workloadSubnet
      loadBalancerSubnet
    ]
  } 
}

module apim '../apim/deployment.bicep' = {
  name: 'apim-deployment'
  params: {
    prefix: localPrefix
    subnetName: '${vnet.name}/apimsubnet'
    addressPrefix: '10.0.0.0/24'
    location: location
    admin_email_address: admin_email_address
  }
}

module aks '../compute/aks.bicep' = {
  name: 'workload-aks'
  params: {
    prefix: localPrefix
    location: location
    subnetId: vnet.properties.subnets[1].id
  }
}

@description('Required to allow the AKS cluster to assign loadbalancers in a different subnet')
module aksNetworkContributorRoleAssignment '../roleAssignments/deployment.bicep' = {
  name: 'hubAksNetworkContributorRoleAssignment'
  params: {
    roleDefinitionId: '4d97b98b-1d4f-4787-a291-c67834d212e7'
    identityId: aks.outputs.info.msi
  }
}

// Outputs
output vnet object = vnet
output vnetName string = vnet.name
output vnetId string = vnet.id
output aksInfo object = aks.outputs.info
