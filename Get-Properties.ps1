$settings = Get-Content -Path "$PSScriptRoot\local.settings.json" | ConvertFrom-Json

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

$siteUrl = $currentSite.Url
$lockstate = $currentSite.LockState
$title = $currentSite.Title

# Property bag property listing
<#
$bag = Get-PnPPropertyBag -Connection $conn
$lists = Get-PnPList -Connection $conn
$appCatalog = ""

foreach($property in $bag){
    Write-Host "$($property.Key): $($property.Value)"
}

if($lists.Title -like "Apps for SharePoint"){
    $appCatalog = "YES"
}
else{
    $appCatalog = "NO"
}
#>

$sqlAdmin = $settings.sqlAdmin
$sqlPass = $settings.sqlPass
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlAdmin, $(ConvertTo-SecureString $sqlPass -AsPlainText -Force)
$cred.Password.MakeReadOnly()

$srv = Get-SqlInstance -ServerInstance $settings.sqlUrl -Credential $cred
$db = $srv.Databases[$settings.sqlDB]
$table = $db.Tables[$settings.sqlDBTable] 

$datatoDB = New-Object -TypeName psobject

$datatoDB | Add-Member -MemberType NoteProperty -Name "id" -Value ""
$datatoDB | Add-Member -MemberType NoteProperty -Name "url" -Value $siteUrl
$datatoDB | Add-Member -MemberType NoteProperty -Name "title" -Value $title
$datatoDB | Add-Member -MemberType NoteProperty -Name "lockstate" -Value $lockstate
$datatoDB | Add-Member -MemberType NoteProperty -Name "storage" -Value 5

try{
    Write-SqlTableData -InputData @datatoDB -PassThru -InputObject $table
}
catch {
    $e = $_.Exception
    $line = $_.InvocationInfo.ScriptLineNumber
    $message = $e.Message
    Write-Error "Exception occured: $message; at line $line"
}