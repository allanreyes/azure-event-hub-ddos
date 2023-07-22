param pipName string
param location string

resource publicip 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: pipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: pipName
    }
    ddosSettings: {
      protectionMode: 'VirtualNetworkInherited'
    }
  }
}

output publicipId string = publicip.id
