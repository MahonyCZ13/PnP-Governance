$settings = Get-Content .\local.settings.json | ConvertFrom-Json

$url = $settings.SiteUrl
$cID = $settings.ClientID

Connect-PnPOnline -Url $url -ClientId $cID -Credentials $settings.Account

$web = Get-PnPWeb

Write-Host $web.Title
