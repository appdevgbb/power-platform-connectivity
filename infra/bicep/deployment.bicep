// Naming convention requirements
targetScope = 'subscription'

param prefix string

param location string

param admin_email_address string

var localPrefix = '${prefix}-${location}'

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
