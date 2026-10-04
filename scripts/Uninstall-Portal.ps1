#requires -Version 5.1
#requires -RunAsAdministrator
param([switch]$DeleteFiles, [switch]$Unattended, [string]$InstallRoot, [string]$ResultPath)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Uninstall-Helpers.ps1')
try {
    if (!$InstallRoot) { $InstallRoot = Split-Path $PSScriptRoot -Parent }
    $root = [IO.Path]::GetFullPath($InstallRoot).TrimEnd([char[]]@('\','/'))
    $state = Get-PortalRemovalState $root
    $manifest = Join-Path $root 'installation.json'
    if (!$Unattended) {
        if ((Read-Host 'Remove this portal service and its named firewall rules? Type REMOVE') -cne 'REMOVE') { exit 0 }
        if ($DeleteFiles -and (Read-Host "Permanently delete ALL files under $root? Type DELETE") -cne 'DELETE') { exit 0 }
    }
    $service = Get-Service -Name $state.service_name -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -ne 'Stopped') {
            Stop-Service -Name $state.service_name -ErrorAction Stop
            (Get-Service -Name $state.service_name).WaitForStatus('Stopped', [TimeSpan]::FromSeconds(30))
        }
        # NSSM owns the service registration; its process must finish before deleting files.
        & (Join-Path $root 'runtime/nssm.exe') remove $state.service_name confirm
        if ($LASTEXITCODE -ne 0) { throw 'Service removal failed; files have not been deleted.' }
        Write-Host 'Portal service removed.'
    }
    foreach ($name in @($state.firewall_names)) {
        Get-NetFirewallRule -Name $name -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction Stop
    }
    Write-Host 'Recorded portal firewall rules removed.'
    $state.status = 'uninstalled-files-preserved'
    $state | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 -LiteralPath $manifest
    if ($DeleteFiles) {
        Set-Location ([IO.Path]::GetTempPath())
        Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction Stop
        if (Test-Path -LiteralPath $root) { throw 'The installation directory could not be completely deleted.' }
        Write-Host "Installed directory deleted: $root"
    } else { Write-Host "All portal files and resources kept at $root" }
    Write-Host 'Other web services and IIS settings were not changed by uninstall.'
    if ($ResultPath) {
        @{success=$true; deleted=[bool]$DeleteFiles; install_directory=$root} | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $ResultPath
    }
    exit 0
} catch {
    if ($ResultPath) {
        @{success=$false; message=[string]$_; install_directory=[string]$root} | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $ResultPath
    }
    Write-Error "Uninstall stopped: $_" -ErrorAction Continue
    exit 1
}
