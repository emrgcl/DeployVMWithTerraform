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
$azureClientSecret = ($sp.Secret | ConvertTo-SecureString -AsPlainText -Force)
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
        encrypted_value = (ConvertTo-SecureString -String $value -AsPlainText -Force | ConvertFrom-SecureString)
        key_id          = (Invoke-RestMethod -Uri "$($script:githubVariablesApiUrl)/public-key" -Headers $headers).key_id
    } | ConvertTo-Json

    Invoke-RestMethod -Method Put -Uri "$($script:githubVariablesApiUrl)/$name" -Headers $headers -Body $body -ContentType "application/json"
}

Add-GitHubVariable "AZURE_CLIENT_ID" $azureClientId -githubApiUrl 
Add-GitHubSecret "AZURE_CLIENT_SECRET" $azureClientSecret
Add-GitHubVariable "AZURE_TENANT_ID" $azureTenantId
Add-GitHubVariable "AZURE_SUBSCRIPTION_ID" $azureSubscriptionId
