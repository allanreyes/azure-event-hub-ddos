param location string
param ehNamespace string
param ehName string
param subnetDefaultId string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: ehNamespace
  location: location
  sku: {
    name: 'Standard'
    capacity: 1
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: false
    zoneRedundant: true
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: eventHubNamespace
  name: ehName
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 1
    }
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

resource eventHubRootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationRules@2021-11-01' = {
  parent: eventHubNamespace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource eventHubNetworkRule 'Microsoft.EventHub/namespaces/networkRuleSets@2022-10-01-preview' = {
  parent: eventHubNamespace
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Deny'
    virtualNetworkRules: [
      {
        subnet: {
          id: subnetDefaultId
        }
      }
    ]
    trustedServiceAccessEnabled: true
  }
}

output eventHubNamespaceId string = eventHubNamespace.id
