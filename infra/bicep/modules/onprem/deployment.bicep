// Naming convention requirements
param prefix string

param location string = resourceGroup().location

// Network Settings
param vnetPrefix string = '10.1.0.0/16'

var localPrefix = '${prefix}-onprem'

var workloadSubnet = {
  name: 'workloadsubnet'
  properties: {
    addressPrefix: '10.1.1.0/24'
    networkSecurityGroup: {
      id: workloadnsg.id
    }
  }
}

var loadBalancerSubnet = {
  name: 'loadbalancersubnet'
  properties: {
    addressPrefix: '10.1.2.0/24'
  }
}

//
// Top Level Resources
//

resource workloadnsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${localPrefix}-workload-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Inbound-Vnet-Http'
        properties: {
          access: 'Allow'
          description: 'Http to Subnet'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '80'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Allow-Inbound-VNET-Https'
        properties: {
          access: 'Allow'
          description: 'Https to Subnet'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

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

module aks '../compute/aks.bicep' = {
  name: 'workload-aks'
  params: {
    prefix: localPrefix
    location: location
    subnetId: '${vnet.id}/subnets/${workloadSubnet.name}'
  }
}

@description('Required to allow the AKS cluster to assign loadbalancers in a different subnet')
module aksNetworkContributorRoleAssignment '../roleAssignments/deployment.bicep' = {
  name: 'onpremAksNetworkContributorRoleAssignment'
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
