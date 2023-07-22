param location string
param vnetId string
param privateEndpointSubnetId string
param ehNamespaceId string
var privateDnsZoneName = contains(location, 'gov') ? 'privatelink.servicebus.usgovcloudapi.net' : 'privatelink.servicebus.windows.net'
var privateEndpoinName = 'pe-eventhub'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'pdns-vnet-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpointStorageTablePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  parent: privateEndpoint
  name: 'eventhubPrivateDnsZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: privateEndpoinName
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'EventHubPrivateLinkConnection'
        properties: {
          privateLinkServiceId: ehNamespaceId
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
  }
}
