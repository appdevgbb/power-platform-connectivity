param vnets array

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'aipapi.azuregbb.com'
  location: 'global'
}

resource dnszonelink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnet, i) in vnets: {
  name: '${dnszone.name}-${i}-link'
  location: 'global'
  parent: dnszone
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: vnet
    }
  }
}]

output name string = dnszone.name
