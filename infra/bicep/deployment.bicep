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
