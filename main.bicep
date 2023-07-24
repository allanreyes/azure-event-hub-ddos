targetScope = 'subscription'

param location string = deployment().location
param rgName string
param ehNamespacePrefix string
param ehName string
param rgSharedName string

var apimName = toLower('apim-${uniqueString(rg.id)}')
var ehNamespace = '${ehNamespacePrefix}-${uniqueString(rg.id)}'
var domain = contains(location, 'gov') ? 'servicebus.usgovcloudapi.net' : 'servicebus.windows.net'
var ehServiceUrl = '${ehNamespace}.${domain}/${ehName}/messages'


resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

resource rgShared 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgSharedName
  location: location
}

module ddos 'modules/ddos.bicep' = {
  scope: rgShared
  name: 'ddos'
  params: {
    ddosPlanName: toLower('ddos-${uniqueString(rgShared.id)}')
    location: location
  }
}

module nsg 'modules/nsg.bicep' = {
  scope: rg
  name: 'nsg'
  params: {
    nsgName: toLower('nsg-${uniqueString(rg.id)}')
    location: location
  }
}

module vnet 'modules/vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    nsgId: nsg.outputs.nsgId
    vnetName: toLower('vnet-${uniqueString(rg.id)}')
    snetName: 'snet-apim'
    location: location
    ddosProtectionPlanId: ddos.outputs.ddosId
  }
}

module publicip 'modules/publicip.bicep' = {
  scope: rg
  name: 'publicip'
  params: {
    pipName: toLower('pip-${uniqueString(rg.id)}')
    location: location
  }
}

module apim 'modules/apim.bicep' = {
  scope: rg
  name: 'apim'
  params: {
    apimName: apimName
    location: location
    publicipId: publicip.outputs.publicipId
    publisherEmail: 'user@contoso.com'
    publisherName: 'Contoso User'
    subnetId: vnet.outputs.subnetId
    ehServiceUrl : 'https://${ehServiceUrl}'
    ehName: ehName
  }
}

module privatelink 'modules/privatelink.bicep' = {
  scope: rg
  name: 'privatelink'
  params: {
    location: location
    ehNamespaceId: eventhub.outputs.eventHubNamespaceId
    privateEndpointSubnetId: vnet.outputs.subnetId
    vnetId: vnet.outputs.vnetId
  }
}

module eventhub 'modules/eventhub.bicep' = {
  scope: rg
  name: 'eventhub'
  params: {
    location: location
    ehName: ehName
    ehNamespace: '${ehNamespacePrefix}-${uniqueString(rg.id)}'
    subnetDefaultId: vnet.outputs.subnetId
  }
}

output ehNamespace string = ehNamespace
output ehServiceUrl string = ehServiceUrl
output apimName string = apimName
