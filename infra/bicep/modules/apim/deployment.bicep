param prefix string
param location string
param subnetId string
param admin_email_address string

var localPrefix = '${prefix}-apim'

resource apimpip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${localPrefix}-pip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: localPrefix
    }
  }
}

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: localPrefix
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
      subnetResourceId: subnetId
    }
    virtualNetworkType: 'External'
    // virtualNetworkType: 'External' // Used for Internal APIM in addtion to the below resources
  }
}
