$repoOwner = "your_github_username"
$repoName = "your_repository_name"
$workflowRunId = "your_workflow_run_id"
$artifactId = "your_artifact_id"
$ghToken = "your_github_token"

$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/actions/runs/$workflowRunId/artifacts/$artifactId"
$headers = @{
    "Accept"        = "application/vnd.github+json"
    "Authorization" = "Bearer $ghToken"
}

$artifact = Invoke-RestMethod -Method Get -Uri $apiUrl -Headers $headers

$artifactCreatedAt = [datetime]::Parse($artifact.created_at)
$artifactRetentionDays = if ($artifact.private) { 30 } else { 90 } # Adjust these values as per your GitHub plan

$daysPassed = [datetime]::UtcNow - $artifactCreatedAt
$daysRemaining = $artifactRetentionDays - $daysPassed.Days

Write-Output "Days remaining for artifact $($artifact.name): $daysRemaining"
