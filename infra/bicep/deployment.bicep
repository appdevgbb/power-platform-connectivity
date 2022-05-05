// Naming convention requirements
targetScope = 'subscription'

param prefix string

param location string

param admin_email_address string

var localPrefix = '${prefix}-${location}'

var records = [
  {
    name: 'hubworkload'
    ipAddress: '10.0.2.4'
  }
  {
    name: 'onpremworkload'
    ipAddress: '10.1.2.4'
  }
]

resource hubRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${localPrefix}-hub'
  location: location
}

resource onpremRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${localPrefix}-onprem'
  location: location
}

module hub 'modules/hub/deployment.bicep' = {
  scope: hubRg
  name: 'hub'
  params: {
    prefix: localPrefix
    location: location
    admin_email_address: admin_email_address
  }
}

module onprem 'modules/onprem/deployment.bicep' = {
  scope: onpremRg
  name: 'onprem'
  params: {
    prefix: localPrefix
    location: location
  }
}

module hubToOnpremPeering 'modules/network/vnetPeering/deployment.bicep' = {
  scope: hubRg
  name: 'hubToOnpremPeering'
  params: {
    localVnetName: hub.outputs.vnetName
    remoteVnetId: onprem.outputs.vnetId
    peeringName: 'hubToOnprem'
  }
}

module onpremtoHubPeering 'modules/network/vnetPeering/deployment.bicep' = {
  scope: onpremRg
  name: 'onpremToHub'
  params: {
    localVnetName: onprem.outputs.vnetName
    remoteVnetId: hub.outputs.vnetId
    peeringName: 'onpremToHub'
  }
}

module dnszone 'modules/network/dnszone/deployment.bicep' = {
  scope: hubRg
  name: 'privateDnsZone'
  params: {
    vnets: [
      hub.outputs.vnetId
      onprem.outputs.vnetId
    ]
  }
}

module aRecords 'modules/network/dnszone/arecord.bicep' = {
  scope: hubRg
  name: 'onpremWorkloadARecord'
  params: {
    dnsZoneName: dnszone.outputs.name
    records: records
  }
}

output hub object = {
  vnetId: hub.outputs.vnetId
  aks: union(records[0], hub.outputs.aksInfo)
}

output onprem object = {
  vnetId: onprem.outputs.vnetId
  aks: union(records[1], onprem.outputs.aksInfo)
}
