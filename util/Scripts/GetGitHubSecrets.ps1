# Set required variables
$githubToken = "your_github_token"
$githubOwner = "emregcl"
$githubRepo = "DeployVMWithTerraform"

# Set the base URL and headers for the GitHub REST API
$githubApiUrl = "https://api.github.com/repos/$githubOwner/$githubRepo/actions/secrets"
$headers = @{
    "Authorization" = "Bearer $githubToken"
    "Accept"        = "application/vnd.github+json"
}

# Function to retrieve a GitHub secret
function Get-GitHubSecret($secretName) {
    $secret = Invoke-RestMethod -Method Get -Uri "$githubApiUrl/$secretName" -Headers $headers
    if ($secret) {
        return $secret
    }
    else {
        Write-Host "Secret not found or access denied"
        return $null
    }
}

# Retrieve secrets
$azureClientIdSecret = Get-GitHubSecret "AZURE_CLIENT_ID"
$azureClientSecretSecret = Get-GitHubSecret "AZURE_CLIENT_SECRET"
$azureTenantIdSecret = Get-GitHubSecret "AZURE_TENANT_ID"
$azureSubscriptionIdSecret = Get-GitHubSecret "AZURE_SUBSCRIPTION_ID"

# Output the secrets
Write-Host "AZURE_CLIENT_ID secret:" $azureClientIdSecret
Write-Host "AZURE_CLIENT_SECRET secret:" $azureClientSecretSecret
Write-Host "AZURE_TENANT_ID secret:" $azureTenantIdSecret
Write-Host "AZURE_SUBSCRIPTION_ID secret:" $azureSubscriptionIdSecret
