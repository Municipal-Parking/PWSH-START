param($Request, $TriggerMetadata)

# Function to Retrieve Access Token
function Get-AccessToken {
    param (
        [string]$TenantId,
        [string]$ClientId,
        [string]$ClientSecret
    )

    $body = @{
        client_id     = $ClientId
        scope         = "https://management.azure.com/.default"
        client_secret = $ClientSecret
        grant_type    = "client_credentials"
    }

    try {
        $tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body
        return $tokenResponse.access_token
    }
    catch {
        Write-Error "Failed to retrieve access token: $_"
        return $null
    }
}

# Function to Query Sentinel Playbooks
function Get-SentinelPlaybooks {
    param ([string]$AccessToken, [string]$SubscriptionId, [string]$ResourceGroupName)

    $url = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Logic/workflows?api-version=2019-05-01"

    $headers = @{
        Authorization = "Bearer $AccessToken"
        "Content-Type" = "application/json"
    }

    try {
        # Retrieve all Logic Apps
        $response = Invoke-RestMethod -Method Get -Uri $url -Headers $headers

        # Filter Sentinel Playbooks
        $playbooks = $response.value | Where-Object {
            ($_.properties.definition.triggers.Http.type -eq "HttpRequest") -or
            ($_.properties.definition.triggers.type -eq "Microsoft.SecurityInsights/AlertRule") -or
            ($_.tags.playbook -ne $null) -or
            ($_.name -like "Sentinel*")
        }

        return $playbooks
    }
    catch {
        Write-Error "Failed to query Sentinel playbooks: $_"
        return $null
    }
}

# Main Script

# Automatic Environment Variables
$ClientId = $env:ClientID           # Azure AD App Registration Client ID
$ClientSecret = $env:ClientSecret   # Azure AD App Registration Client Secret
$TenantId = $env:TenantId           # Azure Tenant ID
$SubscriptionId = $env:SubscriptionId # Azure Subscription ID
$ResourceGroupName = $env:AZURE_RESOURCE_GROUP # Resource Group containing the playbooks

# Debug Logs to Verify Environment Variables
Write-Output "DEBUG: Retrieved Environment Variables"
Write-Output "Client ID: $ClientId"
Write-Output "Subscription ID: $SubscriptionId"
Write-Output "Tenant ID: $TenantId"
Write-Output "Resource Group: $ResourceGroupName"

# Validate Inputs
if (-not $ClientId -or -not $ClientSecret -or -not $TenantId -or -not $SubscriptionId -or -not $ResourceGroupName) {
    Write-Error "One or more required environment variables are missing. Verify configuration."
    return
}

# Retrieve Access Token
$AccessToken = Get-AccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret

if (-not $AccessToken) {
    Write-Error "Failed to retrieve access token. Check your inputs or permissions."
    return
}

# Query Sentinel Playbooks
$Playbooks = Get-SentinelPlaybooks -AccessToken $AccessToken -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName

if (-not $Playbooks) {
    Write-Error "No Sentinel playbooks found or failed to retrieve playbooks."
    return
}

# Output Results
$output = @{
    subscriptionId = $SubscriptionId
    resourceGroupName = $ResourceGroupName
    playbooks = $Playbooks
}

$outputJson = $output | ConvertTo-Json -Depth 6
Write-Output "DEBUG: Retrieved Sentinel Playbooks"
Write-Output $outputJson
