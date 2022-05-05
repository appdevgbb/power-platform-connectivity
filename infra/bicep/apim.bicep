param prefix string
param location string = resourceGroup().location
param vnetName string
param admin_email_address string
param subnetPrefix string


module apim 'modules/apim/deployment.bicep' = {
  name: 'apim-deployment'
  params: {
    prefix: prefix
    subnetName: '${vnetName}/apimsubnet'
    // addressPrefix: '10.0.0.0/24'
    addressPrefix: subnetPrefix
    location: location
    admin_email_address: admin_email_address
  }
}
