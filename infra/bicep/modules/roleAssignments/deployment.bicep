param roleDefinitionId string
param identityId string
param identityType string = 'ServicePrincipal'

@description('This gets the role ID. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#network-contributor')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, identityId, roleDefinition.id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: identityId
    principalType: identityType
  }
}
