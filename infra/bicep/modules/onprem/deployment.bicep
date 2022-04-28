// Naming convention requirements
param prefix string

param location string = resourceGroup().location

// Network Settings
param vnetPrefix string = '10.1.0.0/16'

var localPrefix = '${prefix}-onprem'

var workloadSubnet = {
  name: 'apimsubnet'
  properties: {
    addressPrefix: '10.1.1.0/24'
    networkSecurityGroup: {
      id: workloadnsg.id
    }
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
    ]
  } 
}

// Outputs
output vnet string = vnet.id
