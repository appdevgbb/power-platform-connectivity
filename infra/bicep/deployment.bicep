// Naming convention requirements
param prefix string

param location string = resourceGroup().location

// Network Settings
param vnetPrefix string = '10.0.0.0/16'

param admin_email_address string

var apimSubnet = {
  name: 'apimsubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroup: {
      id: apimnsg.id
    }
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
      {
        service: 'Microsoft.EventHub'
      }
    ]
  }
}

var workloadSubnet = {
  name: 'workloadsubnet'
  properties: {
    addressPrefix: '10.0.1.0/24'       
  }
}

//
// Top Level Resources
//

// See Doc: ["Configure NSG Rules"](https://docs.microsoft.com/en-us/azure/api-management/api-management-using-with-vnet?tabs=stv2#configure-nsg-rules)
// Some rules Borrowed/Found from: https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-create-with-external-vnet-publicip/main.bicep

resource apimnsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${prefix}-apim-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Inbound-Client-to-APIM-80'
        properties: {
          access: 'Allow'
          description: 'Client communication to API Management'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '80'
          direction: 'Inbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Allow-Inbound-Client-to-APIM-443'
        properties: {
          access: 'Allow'
          description: 'Client communication to API Management'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '443'
          direction: 'Inbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Allow-Inbound-Management-Endpoint-Azure-Portal-3443'
        properties: {
          access: 'Allow'
          description: 'Management endpoint for Azure portal and PowerShell	'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '3443'
          direction: 'Inbound'
          priority: 200
          protocol: 'Tcp'
          sourceAddressPrefix: 'ApiManagement'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Allow-Inbound-LB-6390'
        properties: {
          access: 'Allow'
          description: 'Azure Infrastructure Load Balancer (required for Premium service tier)'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '6390'
          direction: 'Inbound'
          priority: 300
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Dependency_to_sync_Rate_Limit_Inbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 310
          direction: 'Inbound'
        }
      }
      {
        name: 'Allow-Outbound-AzStorage-443'
        properties: {
          access: 'Allow'
          description: 'Dependency on Azure Storage'
          destinationAddressPrefix: 'Storage'
          destinationPortRange: '443'
          direction: 'Outbound'
          priority: 400
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Allow-Outbound-AzSQL-1433'
        properties: {
          access: 'Allow'
          description: 'Access to Azure SQL endpoints'
          destinationAddressPrefix: 'SQL'
          destinationPortRange: '1433'
          direction: 'Outbound'
          priority: 410
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Allow-Outbound-AKV-433'
        properties: {
          access: 'Allow'
          description: 'Access to Azure Key Vault'
          destinationAddressPrefix: 'AzureKeyVault'
          destinationPortRange: '433'
          direction: 'Outbound'
          priority: 420
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Publish_DiagnosticLogs_And_Metrics'
        properties: {
          description: 'API Management logs and metrics for consumption by admins and your IT team are all part of the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureMonitor'
          access: 'Allow'
          priority: 430
          direction: 'Outbound'
          destinationPortRanges: [
            '443'
            '12000'
            '1886'
          ]
        }
      }
      {
        name: 'Connect_To_SMTP_Relay_For_SendingEmails'
        properties: {
          description: 'APIM features the ability to generate email traffic as part of the data plane and the management plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 440
          direction: 'Outbound'
          destinationPortRanges: [
            '25'
            '587'
            '25028'
          ]
        }
      }
      {
        name: 'Authenticate_To_Azure_Active_Directory'
        properties: {
          description: 'Connect to Azure Active Directory for developer Portal authentication or for OAuth 2 flow during any proxy authentication'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureActiveDirectory'
          access: 'Allow'
          priority: 450
          direction: 'Outbound'
          destinationPortRanges: [
            '80'
            '443'
          ]
        }
      }
      {
        name: 'Publish_Monitoring_Logs'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 460
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Azure_File_Share_for_GIT'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 470
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_for_Log_to_event_Hub_policy'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '5671'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 480
          direction: 'Outbound'
        }
      }
      {
        name: 'Dependency_on_Redis_Cache_outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '6381-6383'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 490
          direction: 'Outbound'
        }
      }
      {
        name: 'Depenedency_To_sync_RateLimit_Outbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '4290'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 495
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${prefix}-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: [
      apimSubnet
      workloadSubnet
    ]
  } 
}

resource apimpip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${prefix}-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: '${prefix}-apim'
    }
  }
}

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: '${prefix}-apim'
  location: location
  sku: {
    capacity: 1
    name: 'Developer'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicIpAddressId: apimpip.id
    publicNetworkAccess: 'Enabled'
    publisherEmail: admin_email_address
    publisherName: prefix
    virtualNetworkConfiguration: {
      subnetResourceId: '${vnet.id}/subnets/${apimSubnet.name}'
    }
    virtualNetworkType: 'External'
    // virtualNetworkType: 'External' // Used for Internal APIM in addtion to the below resources
  }
}

// <----- Resources for Internal APIM

// resource apimPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   dependsOn: [
//     apim
//   ]
//   name: 'privatelink.azure-api.net'
//   location: 'global'
// }

// resource apimPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   name: '${apimPrivateDnsZone.name}/${apimPrivateDnsZone.name}-link'
//   location: 'global'
//   properties: {
//     virtualNetwork: {
//       id: vnet.id
//     }
//     registrationEnabled: false
//   }
// }

// resource apimPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
//   name: '${apim.name}-privendpoint'
//   location: location
//   properties: {
//     subnet: {
//       id: '${vnet.id}/subnets/${apimSubnet.name}'
//     }
//     privateLinkServiceConnections: [
//       {
//         name: '${apim.name}-privendpoint'
//         properties: {
//           privateLinkServiceId: apim.id
//           groupIds: [
//             'Gateway'
//           ]
//         }
//       }
//     ]
//   }
// }

// resource apimPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
//   name: '${apimPrivateEndpoint.name}/default'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: replace(apimPrivateDnsZone.name, '.', '-')
//         properties: {
//           privateDnsZoneId: apimPrivateDnsZone.id
//         }
//       }
//     ]
//   }
// }

// End Internal APIM -----> 

// Outputs
output vnet string = vnet.id
