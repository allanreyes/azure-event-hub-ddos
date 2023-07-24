# Sign-in to Azure

Connect-AzAccount -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # -Environment AzureUSGovernment
Set-AzContext -Subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Update values

$resourceGroupName = "rgEventHubDDOS"
$sharedResourceGroupName = "rgSharedResources"
$location = "canadacentral" # "usgovvirginia"
$ehNamespacePrefix = "ehn"
$ehName = "eh"

# Deploy template

$deployment = New-AzSubscriptionDeployment -Name "$resourceGroupName-deployment" `
    -Location $location `
    -TemplateFile ".\main.bicep" `
    -TemplateParameterObject @{
    rgName            = $resourceGroupName
    rgSharedName      = $sharedResourceGroupName
    ehNamespacePrefix = $ehNamespacePrefix
    ehName            = $ehName
}
    
Write-Host "Deployment $($deployment.ProvisioningState)"

# Generate Event Hub SAS Token

$ehKey = Get-AzEventHubKey -ResourceGroupName $resourceGroupName `
    -NamespaceName $deployment.Outputs["ehNamespace"].Value `
    -Name RootManageSharedAccessKey

[Reflection.Assembly]::LoadWithPartialName("System.Web") | out-null
$URI = $deployment.Outputs["ehServiceUrl"].Value
$Access_Policy_Name = "RootManageSharedAccessKey"
$Access_Policy_Key = $ehKey.PrimaryKey

$Expires = ([DateTimeOffset]::Now.ToUnixTimeSeconds()) + 3000
$SignatureString = [System.Web.HttpUtility]::UrlEncode($URI) + "`n" + [string]$Expires
$HMAC = New-Object System.Security.Cryptography.HMACSHA256
$HMAC.key = [Text.Encoding]::ASCII.GetBytes($Access_Policy_Key)
$Signature = $HMAC.ComputeHash([Text.Encoding]::ASCII.GetBytes($SignatureString))
$Signature = [Convert]::ToBase64String($Signature)
$SASToken = "SharedAccessSignature sr=" + [System.Web.HttpUtility]::UrlEncode($URI) + "&sig=" + [System.Web.HttpUtility]::UrlEncode($Signature) + "&se=" + $Expires + "&skn=" + $Access_Policy_Name

# Test sending a message to the EventHub

$body = @{
    "message" = "Hello World!"
} | ConvertTo-Json

$headers = @{
    "Authorization" = $SASToken
}

Write-Host "Sending a message to the Event Hub directly: https://$($URI)"
Write-Warning "This will fail because the Event Hub is not configured to accept messages from the Internet."
Invoke-WebRequest -Method 'Post' -Uri "https://$($URI)/messages" -Body $body `
    -Headers $headers

$apim = Get-AzApiManagement -ResourceGroupName $resourceGroupName `
    -Name $deployment.Outputs["apimName"].Value
$apimUrl = "$($apim.RuntimeUrl)/$($ehName)" 

Write-Host "Sending a message to the API Management: $apimUrl"
Write-Warning "This will succeed because API Management is configured to accept messages from the Internet and forward it to Event Hub."
Invoke-WebRequest -Method 'Post' -Uri $apimUrl -Body $body `
        -Headers $headers -ContentType "application/json"