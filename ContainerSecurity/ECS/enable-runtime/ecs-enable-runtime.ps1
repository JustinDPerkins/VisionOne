param(
    [string]$apiKey
)
# Check if the API key is provided
if (-not $apiKey) {
    Write-Host "Please provide the API key using the -apiKey parameter."
    Exit
}

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $apiKey")
$headers.Add("Content-Type", "application/json")

$response = Invoke-RestMethod 'https://api.xdr.trendmicro.com/beta/containerSecurity/amazonEcsClusters' -Method 'GET' -Headers $headers
$ids = $response.items.id

foreach ($id in $ids) {
    # Collect Current Cluster Settings to determine whether to Enable V1 CS Runtime Features
    $check_current_setting = Invoke-RestMethod "https://api.xdr.trendmicro.com/beta/containerSecurity/amazonEcsClusters/$id" -Method 'GET' -Headers $headers

    # Check if runtimeSecurityEnabled and vulnerabilityScanEnabled are set to True
    if ($check_current_setting.runtimeSecurityEnabled -eq $true -and $check_current_setting.vulnerabilityScanEnabled -eq $true) {
        Write-Host "Runtime Security and Vulnerability Scan are already enabled for Cluster ID: $id"
        # Perform additional actions if needed
    } else {
        Write-Host "Enabling Runtime Security and/or Vulnerability Scan for Cluster ID: $id"
        # Perform additional actions for clusters with disabled settings
        $body = @{
            "vulnerabilityScanEnabled" = $true
            "runtimeSecurityEnabled" = $true
        } | ConvertTo-Json

        Invoke-RestMethod "https://api.xdr.trendmicro.com/beta/containerSecurity/amazonEcsClusters/$id" -Method 'PATCH' -Headers $headers -Body $body
        Write-Host "Enabled Successfully: $id"
    }
}


