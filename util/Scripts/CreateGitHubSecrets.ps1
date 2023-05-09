param (
    [string]$tenantId,
    [string]$subscriptionId,
    [string]$resourceGroupName,
    [string]$githubToken,
    [string]$githubOwner,
    [string]$githubRepo
)

# Login to Azure
Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId

# Create a Service Principal
$spName = "$githubOwner-GitHub-Actions-SPN"
$sp = New-AzADServicePrincipal -DisplayName $spName -SkipAssignment

if ($null -eq $sp -or $null -eq $sp.Id) {
    throw "Failed to create the Service Principal. Please check the Azure account connection and try again."
}


# Retrieve the resource group
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName

# Assign the "Contributor" role to the Service Principal on the resource group
New-AzRoleAssignment -ApplicationId $sp.ApplicationId -RoleDefinitionName "Contributor" -ResourceGroupName $resourceGroup.ResourceGroupName

# Retrieve the required values
$azureClientId = $sp.ApplicationId
$azureClientSecret = ($sp.Secret | Convertfrom-SecureString -AsPlainText )
$azureTenantId = $tenantId
$azureSubscriptionId = $subscriptionId

# Create GitHub secrets using GitHub REST API
$headers = @{
    "Authorization" = "Bearer $githubToken"
    "Accept"        = "application/vnd.github+json"
}

$githubApiUrl = "https://api.github.com/repos/$githubOwner/$githubRepo/actions/secrets"

function Add-GitHubSecret($name, $value) {
    $body = @{
        encrypted_value = (ConvertTo-SecureString -String $value -AsPlainText -Force | ConvertFrom-SecureString)
        key_id          = (Invoke-RestMethod -Uri "$($script:githubApiUrl)/public-key" -Headers $headers).key_id
    } | ConvertTo-Json

    Invoke-RestMethod -Method Put -Uri "$($script:githubApiUrl)/$name" -Headers $headers -Body $body -ContentType "application/json"
}
$githubVariablesApiUrl = "https://api.github.com/repos/$githubOwner/$githubRepo/actions/variables"
function Add-GitHubVariable($name, $value) {
    $body = @{
        name = $Name
        value = $Value
      } | ConvertTo-Json
   $Headers = @{
    Authorization = "Bearer $script:githubToken"
   }
    Invoke-RestMethod -Method Post -Uri "$($script:githubVariablesApiUrl)" -Headers $headers -Body $body -ContentType "application/json"
}

try {
Add-GitHubVariable "AZURE_CLIENT_ID" $azureClientId -githubApiUrl -erroraction stop 
Add-GitHubSecret "AZURE_CLIENT_SECRET" $azureClientSecret -erroraction stop
Add-GitHubSecret "GH_TOKEN" $githubToken -erroraction stop
Add-GitHubVariable "AZURE_TENANT_ID" $azureTenantId -erroraction stop   
Add-GitHubVariable "AZURE_SUBSCRIPTION_ID" $azureSubscriptionId -erroraction stop
write-verbose "Successfully created the GitHub secrets and variables."
Write-Output "Azure_Client_Id: $azureClientId"
Write-output "Azure_Client_Secret: $azureClientSecret"
Write-output "NOTE: Please note Azure_client_Secret, as it will be only visible this time."
write-output "Azure_Tenant_Id: $azureTenantId"
write-output "Azure_Subscription_Id: $azureSubscriptionId"
write-output "GitHub_Token: $githubToken"

}
catch {
    throw "Failed to create the GitHub secrets. Please check the GitHub token and try again."
}
