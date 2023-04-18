param (
    [string]$tenantId,
    [string]$subscriptionId,
    [string]$githubToken,
    [string]$githubOwner,
    [string]$githubRepo
)

# Login to Azure
Connect-AzAccount -TenantId $tenantId -SubscriptionId $subscriptionId

# Create a Service Principal
$spName = "GitHub-Actions-SPN"
$sp = New-AzADServicePrincipal -DisplayName $spName -SkipAssignment

# Assign the "Contributor" role to the Service Principal
New-AzRoleAssignment -ObjectId $sp.ObjectId -RoleDefinitionName "Contributor"

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
        key_id          = (Invoke-RestMethod -Uri "$githubApiUrl/public-key" -Headers $headers).key_id
    } | ConvertTo-Json

    Invoke-RestMethod -Method Put -Uri "$githubApiUrl/$name" -Headers $headers -Body $body -ContentType "application/json"
}

Add-GitHubSecret "AZURE_CLIENT_ID" $azureClientId
Add-GitHubSecret "AZURE_CLIENT_SECRET" $azureClientSecret
Add-GitHubSecret "AZURE_TENANT_ID" $azureTenantId
Add-GitHubSecret "AZURE_SUBSCRIPTION_ID" $azureSubscriptionId
