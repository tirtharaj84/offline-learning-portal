$ErrorActionPreference='Stop'
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts/Setup-Helpers.ps1')
# All Windows/service commands below are mocks; no real services are touched.
$script:ports=@();$script:state='Running';$script:siteState='Started';$script:owner=4
$script:stopCount=0;$script:startCount=0;$script:release=$true;$script:inventoryFailure=$false
function Get-NetTCPConnection {
    param($State,$ErrorAction)
    if ($script:inventoryFailure) { throw 'Inventory failed' }
    foreach($p in $script:ports){[pscustomobject]@{LocalPort=$p;OwningProcess=$script:owner}}
}
function Get-Service {
    param($Name,$ErrorAction)
    $s=[pscustomobject]@{Status=$script:state}
    $s | Add-Member -MemberType ScriptMethod -Name WaitForStatus -Value { param($Status,$Timeout) }
    $s
}
function Import-Module { param($Name,$ErrorAction) }
function Get-Website {
    [pscustomobject]@{Name='School IIS';State=$script:siteState;Bindings=[pscustomobject]@{Collection=@([pscustomobject]@{protocol='http';bindingInformation='*:80:'})}}
}
function Stop-Service {
    param($Name,$ErrorAction)
    if($Name -ne 'W3SVC'){throw 'Unexpected service mutation'}
    $script:stopCount++;$script:state='Stopped'
    if($script:release){$script:ports=@($script:ports | Where-Object {$_ -ne 80})}
}
function Start-Service {param($Name,$ErrorAction);if($Name -ne 'W3SVC'){throw 'Unexpected restore'};$script:startCount++;$script:state='Running'}
function Start-Sleep {param($Milliseconds)}
function Assert($Condition,[string]$Message){if(!$Condition){throw "FAIL: $Message"};Write-Output "PASS: $Message"}
function Throws([scriptblock]$Action){try{& $Action | Out-Null;return $false}catch{return $true}}
Assert ((Get-PortalFreePort) -eq 80) 'Use port 80 when available'
$script:ports=@(80,8080)
Assert ((Get-PortalFreePort) -eq 8081) 'Skip occupied port 80 and alternative 8080'
$script:inventoryFailure=$true
Assert (Throws {Get-PortalFreePort}) 'Inventory failure does not imply a free port'
$script:inventoryFailure=$false;$script:ports=@(80);$script:owner=999
Assert (Throws {Stop-PortalIisForPort80}) 'Do not stop IIS for an unrelated process'
Assert ($script:stopCount -eq 0) 'Unrelated owner causes no service changes'
$script:owner=4;$script:siteState='Stopped'
Assert (Throws {Stop-PortalIisForPort80}) 'Stopped IIS binding is not active-owner evidence'
$script:siteState='Started';$script:state='Stopped'
Assert (Throws {Stop-PortalIisForPort80}) 'Do not act when IIS is not running'
$script:state='Running';$script:release=$true
Stop-PortalIisForPort80
Assert ($script:stopCount -eq 1 -and @($script:ports).Count -eq 0) 'Stop only W3SVC and confirm port release'
$script:ports=@(80);$script:state='Running';$script:release=$false
Assert (Throws {Stop-PortalIisForPort80}) 'Shared HTTP.sys port still occupied returns failure'
Assert ($script:startCount -eq 1 -and $script:state -eq 'Running') 'Restore IIS after unsuccessful port release'
Write-Output '10 helper assertions passed (mocked Windows commands).'
