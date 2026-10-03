#requires -Version 5.1
#requires -RunAsAdministrator
param([switch]$DeleteFiles)
$ErrorActionPreference='Stop'
try {
    $root=Split-Path $PSScriptRoot -Parent
    $manifest=Join-Path $root 'installation.json'
    if (!(Test-Path $manifest)) { throw 'Run Uninstall.bat from the installed folder. An ownership record is required.' }
    $state=Get-Content -Raw $manifest | ConvertFrom-Json
    if ([IO.Path]::GetFullPath($state.install_directory).TrimEnd('\') -ine [IO.Path]::GetFullPath($root).TrimEnd('\')) { throw 'Ownership record does not match this folder.' }
    $service=Get-Service -Name $state.service_name -ErrorAction SilentlyContinue
    if ($service) {
        $key="HKLM:\SYSTEM\CurrentControlSet\Services\$($state.service_name)\Parameters"
        $app=(Get-ItemProperty $key -Name Application).Application
        if ($app -ine $state.nginx_application) { throw 'Service points to a different application. No removal performed.' }
    }
    if ((Read-Host 'Remove this portal service and its named firewall rules? Type REMOVE') -cne 'REMOVE') { exit 0 }
    if ($DeleteFiles -and (Read-Host "Back up first. Permanently delete ALL files under $root? Type DELETE") -cne 'DELETE') { exit 0 }
    if ($service) {
        if ($service.Status -ne 'Stopped') { Stop-Service $state.service_name; (Get-Service $state.service_name).WaitForStatus('Stopped',[TimeSpan]::FromSeconds(30)) }
        & (Join-Path $root 'runtime\nssm.exe') remove $state.service_name confirm
        if ($LASTEXITCODE -ne 0) { throw 'Service removal failed.' }
    }
    foreach ($name in @($state.firewall_names)) { Get-NetFirewallRule -Name $name -ErrorAction SilentlyContinue | Remove-NetFirewallRule }
    $state.status='uninstalled-files-preserved'
    $state | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $manifest
    if ($DeleteFiles) { Set-Location $env:TEMP; Remove-Item -LiteralPath $root -Recurse -Force; Write-Host 'Installed folder deleted.' }
    else { Write-Host "Service/rules removed. Files and school resources preserved at $root." }
    Write-Host 'Windows computer name was not changed. No shared System32 NSSM copy was removed.'
    exit 0
} catch { Write-Error "Uninstall stopped: $_" -ErrorAction Continue; exit 1 }
