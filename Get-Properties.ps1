$settings = Get-Content -Path "$PSScriptRoot\local.settings.json" | ConvertFrom-Json

$connectionParameters = @{
    ClientID = $settings.ClientID
    Thumbprint = $settings.thumbprint
    Tenant = $settings.tenant
    TenantAdminUrl = $settings.adminUrl
}

try {
    $conn = Connect-PnPOnline -Url $settings.rootUrl @connectionParameters -ReturnConnection
    $allSites = Get-PnPTenantSite -Connection $conn -Detailed
    
}
catch {
    $e = $_.Exception
    $line = $_.InvocationInfo.ScriptLineNumber
    $message = $e.Message
    Write-Error "Exception occured: $message; at line $line"
}

$sqlAdmin = $settings.sqlAdmin
$sqlPass = $settings.sqlPass
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlAdmin, $(ConvertTo-SecureString $sqlPass -AsPlainText -Force)
$cred.Password.MakeReadOnly()

$srv = Get-SqlInstance -ServerInstance $settings.sqlUrl -Credential $cred
$db = $srv.Databases[$settings.sqlDB]
$table = $db.Tables[$settings.sqlDBTable] 

foreach($currentSite in $allSites){
    
    Connect-PnPOnline -Url $currentSite.Url -Connection $conn @connectionParameters

    $site = Get-PnPSite -Includes Usage
    $lists = Get-PnPList
    $storage = [math]::Round($site.Usage.Storage / 1000000,2)
    $percentage = [math]::Round($site.Usage.StoragePercentageUsed,2)
    
    $appCatalog = ""
    if($lists.Title -like "Apps for SharePoint"){
        $appCatalog = "YES"
    } else{
        $appCatalog = "NO"
    }

    $scriptValue = ""
    if($currentSite.DenyAddAndCustomizePages.value__ -eq 2){
        $scriptValue = "FALSE"
    } else {
        $scriptValue = "TRUE"
    }

    $datatoDB = New-Object -TypeName psobject

    $datatoDB | Add-Member -MemberType NoteProperty -Name "id" -Value ""
    $datatoDB | Add-Member -MemberType NoteProperty -Name "url" -Value $currentSite.Url
    $datatoDB | Add-Member -MemberType NoteProperty -Name "title" -Value $currentSite.Title
    $datatoDB | Add-Member -MemberType NoteProperty -Name "lockstate" -Value $currentSite.LockState
    $datatoDB | Add-Member -MemberType NoteProperty -Name "customScripts" -Value $scriptValue
    $datatoDB | Add-Member -MemberType NoteProperty -Name "SPsiteTemplate" -Value $currentSite.Template
    $datatoDB | Add-Member -MemberType NoteProperty -Name "SPSiteLocaleId" -Value $currentSite.LocaleId
    $datatoDB | Add-Member -MemberType NoteProperty -Name "storagePercentage" -Value $percentage
    $datatoDB | Add-Member -MemberType NoteProperty -Name "storageMB" -Value $storage
    $datatoDB | Add-Member -MemberType NoteProperty -Name "appCatalog" -Value $appCatalog 


    try{
        Write-SqlTableData -InputData @datatoDB -PassThru -InputObject $table | Out-Null
    }
    catch {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $message = $e.Message
        Write-Error "Exception occured: $message; at line $line"
    }

    Disconnect-PnPOnline
    
}

# Property bag property listing
<#
$bag = Get-PnPPropertyBag -Connection $conn
 -Connection $conn
$appCatalog = ""

foreach($property in $bag){
    Write-Host "$($property.Key): $($property.Value)"
}
#>







#>