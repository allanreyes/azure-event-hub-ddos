param location string
param ddosPlanName string

resource ddos 'Microsoft.Network/ddosProtectionPlans@2022-11-01' = {
  name: ddosPlanName
  location: location
}

output ddosId string = ddos.id
