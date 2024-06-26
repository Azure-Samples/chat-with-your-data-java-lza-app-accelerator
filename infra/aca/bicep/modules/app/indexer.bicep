param name string
param location string = resourceGroup().location
param tags object = {}

param identityName string
param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param serviceName string = 'indexer'
param exists bool

@description('The environment variables for the container')
param env array = []

resource indexerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module app '../host/container-app-upsert.bicep' = {
  name: '${serviceName}-container-app'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    identityType: 'UserAssigned'
    identityName: indexerIdentity.name
    exists: exists
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    targetPort: 8080
    env: union(env, [
      {
        name: 'AZURE_CLIENT_ID'
        value: indexerIdentity.properties.clientId
      }
     
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
      
    ])
    
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

output SERVICE_INDEXER_IDENTITY_PRINCIPAL_ID string = indexerIdentity.properties.principalId
output SERVICE_INDEXER_NAME string = app.outputs.name
output SERVICE_INDEXER_URI string = app.outputs.uri
output SERVICE_INDEXER_IMAGE_NAME string = app.outputs.imageName
