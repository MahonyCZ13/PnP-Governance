# Sandbox script

$settings = Get-Content -Path "$PSScriptRoot\local.settings.json" | ConvertFrom-Json

$connectionParameters = @{
    ClientID = $settings.ClientID
    Thumbprint = $settings.thumbprint
    Tenant = $settings.tenant
    TenantAdminUrl = $settings.adminUrl
}

$url = $settings.SiteUrl

try {
    #$conn = Connect-PnPOnline -Url $url @connectionParameters -ReturnConnection
    #$currentSite = Get-PnPTenantSite -Connection $conn -Detailed -Identity $url
    
}
catch {
    $e = $_.Exception
    $line = $_.InvocationInfo.ScriptLineNumber
    $message = $e.Message
    Write-Error "Exception occured: $message; at line $line"
}

Connect-PnPOnline -Url $url @connectionParameters
#Add-PnPSiteCollectionAppCatalog -Site $url
$web = Get-PnPWeb
Write-Host $web.Title
Write-Host "Done!" -ForegroundColor Green
