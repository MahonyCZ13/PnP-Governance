$settings = Get-Content .\local.settings.json | ConvertFrom-Json

$connectionParameters = @{
    ClientID = $settings.ClientID
    Thumbprint = $settings.thumbprint
    Tenant = $settings.tenant
    TenantAdminUrl = $settings.adminUrl
}

$url = $settings.SiteUrl

Connect-PnPOnline -Url $url @connectionParameters

$web = Get-PnPWeb

Write-Host $web.Title
