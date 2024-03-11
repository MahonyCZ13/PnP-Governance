$settings = Get-Content .\local.settings.json | ConvertFrom-Json

$connectionParameters = @{
    ClientID = $settings.ClientID
    Thumbprint = $settings.thumbprint
    Tenant = $settings.tenant
    TenantAdminUrl = $settings.adminUrl
}
$url = $settings.SiteUrl

try {
    $conn = Connect-PnPOnline -Url $url @connectionParameters -ReturnConnection
    $currentSite = Get-PnPTenantSite -Connection $conn -Detailed -Identity $url
    
}
catch {
    $e = $_.Exception
    $line = $_.InvocationInfo.ScriptLineNumber
    $message = $e.Message
    Write-Error "Exception occured: $message; at line $line"
}
finally {
    Write-Host $currentSite.Title -ForegroundColor Yellow
}

