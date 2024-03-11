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
    $message = Get-Error
    Write-Error "Error occured at: $message"
}
finally {
    Write-Host $currentSite.Title -ForegroundColor Yellow
}







