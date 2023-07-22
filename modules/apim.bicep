param publisherEmail string
param publisherName string
param publicipId string
param sku string = 'Developer'
param location string
param apimName string
param subnetId string
param ehServiceUrl string
param ehName string

resource apim 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: apimName
  location: location
  sku: {
    name: sku
    capacity: 1
  }
  zones:  null
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: 'External'
    publicIpAddressId: publicipId
    virtualNetworkConfiguration: {
      subnetResourceId: subnetId
    }
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
  }
}

resource service_apimCary_name_echo_api 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apim
  name: 'echo-api'
  properties: {
    displayName: 'Echo API'
    apiRevision: '1'
    subscriptionRequired: true
    serviceUrl: 'http://echoapi.cloudapp.net/api'
    path: 'echo'
    protocols: [
      'https'
    ]
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    isCurrent: true
  }
}

resource echo_api_retrieve 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  parent: service_apimCary_name_echo_api
  name: 'retrieve-resource'
  properties: {
    displayName: 'Retrieve resource'
    method: 'GET'
    urlTemplate: '/resource'
    templateParameters: []
    description: 'A demonstration of a GET call on a sample resource. It is handled by an "echo" backend which returns a response equal to the request (the supplied headers and body are being returned as received).'
    request: {
      queryParameters: [
        {
          name: 'param1'
          description: 'A sample parameter that is required and has a default value of "sample".'
          type: 'string'
          defaultValue: 'sample'
          required: true
          values: [
            'sample'
          ]
        }
        {
          name: 'param2'
          description: 'Another sample parameter, set to not required.'
          type: 'number'
        }
      ]
    }
    responses: [
      {
        statusCode: 200
        description: 'Returned in all cases.'
      }
    ]
  }
}

resource service_apimCary_name_event_hub 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: apim
  name: 'event-hub'
  properties: {
    displayName: 'Event Hub'
    apiRevision: '1'
    subscriptionRequired: false
    serviceUrl: ehServiceUrl
    path: ehName
    protocols: [
      'https'
    ]
    isCurrent: true
  }
}

resource service_apimCary_name_event_hub_add_message 'Microsoft.ApiManagement/service/apis/operations@2022-08-01' = {
  parent: service_apimCary_name_event_hub
  name: 'add-message'
  properties: {
    displayName: 'Add Message'
    method: 'POST'
    urlTemplate: '/'
    templateParameters: []
    request: {
      description: '{\n"test": "123"\n}'
      queryParameters: []
      headers: []
      representations: []
    }
    responses: []
  }
}
