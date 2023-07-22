
param location string
param vnetName string
param vnetAddressPrefix string = '10.0.0.0/16'
param snetName string
param snetPrefix string = '10.0.0.0/24'
param nsgId string
param ddosProtectionPlanId string
param apimSnetServinceEndpoints array = [
  {
    service: 'Microsoft.Storage'
  }
  {
    service: 'Microsoft.Sql'
  }
  {
    service: 'Microsoft.EventHub'
  }
  {
    service: 'Microsoft.KeyVault'
  }
  {
    service: 'Microsoft.ServiceBus'
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: snetName
        properties: {
          addressPrefix: snetPrefix
          networkSecurityGroup: {
            id: nsgId
          }
          serviceEndpoints: apimSnetServinceEndpoints
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: true
    ddosProtectionPlan: {
       id: ddosProtectionPlanId
    }
  }
}

output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id
