#requires -Version 5.1
#requires -RunAsAdministrator
param([string]$ConfigPath, [switch]$Unattended, [string]$ResultPath)
$ErrorActionPreference = 'Stop'
$package = Split-Path $PSScriptRoot -Parent
$state = $null
function Native([string]$exe, [string[]]$arguments) {
    & $exe @arguments
    if ($LASTEXITCODE -ne 0) { throw "Command failed ($LASTEXITCODE): $exe $($arguments -join ' ')" }
}
function Save-State { $state | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 (Join-Path $state.install_directory 'installation.json') }
try {
    if (!$ConfigPath) { $ConfigPath = Join-Path $package 'portal-settings.json' }
    $cfg = Get-Content -Raw -LiteralPath $ConfigPath | ConvertFrom-Json
    $cfg.offer_computer_rename = $false
    $cfg.enable_hostname_discovery_rules = $false
    if ($cfg.offer_computer_rename -isnot [bool] -or $cfg.enable_hostname_discovery_rules -isnot [bool]) { throw 'Rename and hostname discovery settings must be JSON true or false.' }
    $dest = [string]$cfg.install_directory
    if ($dest -notmatch '^[A-Za-z]:\\(?:[A-Za-z0-9_-]+\\)*[A-Za-z0-9_-]+$') { throw 'Use a dedicated absolute install path with no spaces, for example C:\LearningPortal.' }
    if ($cfg.hostname -notmatch '^[A-Za-z][A-Za-z0-9-]{0,14}$' -or $cfg.hostname.EndsWith('-')) { throw 'Hostname must start with a letter, contain only letters/numbers/hyphens, and be at most 15 characters.' }
    if ($cfg.service_name -notmatch '^[A-Za-z][A-Za-z0-9_]{0,63}$') { throw 'Use a service name containing only letters, digits and underscores.' }
    $port = [int]$cfg.http_port
    if ($port -lt 1 -or $port -gt 65535) { throw 'http_port must be between 1 and 65535.' }
    $profiles = @($cfg.firewall_profiles)
    if (!$profiles.Count -or @($profiles | Where-Object { $_ -notin @('Private','Domain','Public') }).Count) { throw 'firewall_profiles must contain Private, Domain, or Public.' }
    if ($cfg.firewall_remote_address -notin @('LocalSubnet','Any')) { throw 'firewall_remote_address must be LocalSubnet or Any.' }
    if (Test-Path $dest) { throw "$dest already exists. This installer does not overwrite an installation. Back up and review it first." }
    if (Get-Service -Name $cfg.service_name -ErrorAction SilentlyContinue) { throw 'The chosen Windows service name is already in use.' }
    # Query all listeners so a failed inventory is not mistaken for a free port.
    $listeners = @(Get-NetTCPConnection -State Listen -ErrorAction Stop)
    if (@($listeners | Where-Object LocalPort -eq $port).Count) {
        if ($Unattended) { throw "TCP $port became occupied. Return to setup and choose a free port." }
        Write-Warning "TCP $port is occupied. IIS or another application may own it."
        $listeners | Where-Object LocalPort -eq $port | Select-Object LocalAddress,LocalPort,OwningProcess | Format-Table
        if (Get-Service W3SVC -ErrorAction SilentlyContinue) { Write-Host 'IIS W3SVC is installed; this alone does not prove it owns this port. For HTTP.sys diagnostics use: netsh http show servicestate' }
        $answer = Read-Host 'Enter an alternative port (for example 8080), or press Enter to cancel. Existing services will not be stopped'
        if (!$answer) { Write-Host 'Cancelled before installation.'; exit 0 }
        $alternative = 0
        if (![int]::TryParse($answer,[ref]$alternative) -or $alternative -lt 1 -or $alternative -gt 65535) { throw 'Alternative port must be an integer between 1 and 65535.' }
        if (@($listeners | Where-Object LocalPort -eq $alternative).Count) { throw "TCP $alternative is also occupied. No installation was performed." }
        $port = $alternative
        $cfg.http_port = $port
    }
    foreach ($rel in @('vendor\nginx\nginx.exe','vendor\nginx\conf\mime.types','vendor\nssm.exe','web\index.html','web\catalog.json','scripts\generate_catalog.py','docs\nginx-template.conf','LICENSE.txt','LICENSE_STATUS.md','THIRD_PARTY_NOTICES.md','vendor\PROVENANCE.json','vendor\nssm-notices\README.txt','vendor\nssm-notices\ChangeLog.txt')) {
        if (!(Test-Path -LiteralPath (Join-Path $package $rel) -PathType Leaf)) { throw "Package is missing $rel. See docs\DEPENDENCIES.md." }
    }
    Get-Content -Raw (Join-Path $package 'web\catalog.json') | ConvertFrom-Json | Out-Null
    $prefix = "$($cfg.service_name)-"
    $rules = @("${prefix}HTTP")
    if ($cfg.enable_hostname_discovery_rules) { $rules += @("${prefix}LLMNR","${prefix}NetBIOS") }
    foreach ($name in $rules) { if (Get-NetFirewallRule -Name $name -ErrorAction SilentlyContinue) { throw "Firewall rule $name already exists. Review it first." } }
    Write-Host "Install: $dest | Service: $($cfg.service_name) | TCP: $port"
    Write-Host "Firewall profiles: $($profiles -join ', ') | Remote addresses: $($cfg.firewall_remote_address)"
    if (!$Unattended -and (Read-Host 'Continue? Type YES') -cne 'YES') { Write-Host 'Cancelled.'; exit 0 }
    New-Item -ItemType Directory -Path $dest | Out-Null
    # Record ownership early so a partial installation can be inspected/uninstalled.
    $state = [ordered]@{ schema_version=1; package_version='1.1.0'; iis_service_stopped_by_setup=([bool]$cfg.iis_service_stopped_by_setup); install_directory=$dest; service_name=[string]$cfg.service_name; nginx_application=(Join-Path $dest 'runtime\nginx\nginx.exe'); firewall_names=$rules; hostname=[string]$cfg.hostname; port=$port; status='partial'; installed_at=(Get-Date).ToString('o') }
    Save-State
    New-Item -ItemType Directory -Path (Join-Path $dest 'runtime') | Out-Null
    Copy-Item -LiteralPath (Join-Path $package 'vendor\nginx') -Destination (Join-Path $dest 'runtime\nginx') -Recurse
    Copy-Item -LiteralPath (Join-Path $package 'vendor\nssm.exe') -Destination (Join-Path $dest 'runtime\nssm.exe')
    Copy-Item -LiteralPath (Join-Path $package 'vendor\nssm-notices') -Destination (Join-Path $dest 'runtime\nssm-notices') -Recurse
    Copy-Item -LiteralPath (Join-Path $package 'vendor\PROVENANCE.json') -Destination (Join-Path $dest 'runtime\PROVENANCE.json')
    foreach ($dir in @('web','scripts','docs')) { Copy-Item -LiteralPath (Join-Path $package $dir) -Destination (Join-Path $dest $dir) -Recurse }
    $cfg | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 (Join-Path $dest 'portal-settings.json')
    foreach ($file in @('Uninstall.bat','Rebuild_Catalog.bat','README.md','LICENSE_STATUS.md','LICENSE.txt','THIRD_PARTY_NOTICES.md','ACKNOWLEDGEMENTS.md','RELEASE_NOTES.md')) { Copy-Item -LiteralPath (Join-Path $package $file) -Destination $dest }
    $nginxDir = Join-Path $dest 'runtime\nginx'
    # Create runtime directories explicitly; empty folders can be lost in ZIPs.
    foreach ($relative in @('logs','temp','temp\client_body_temp','temp\proxy_temp','temp\fastcgi_temp','temp\uwsgi_temp','temp\scgi_temp')) {
        New-Item -ItemType Directory -Force -Path (Join-Path $nginxDir $relative) | Out-Null
    }
    $template = Get-Content -Raw (Join-Path $package 'docs\nginx-template.conf')
    $conf = $template.Replace('__PORT__',[string]$port).Replace('__HOSTNAME__',[string]$cfg.hostname).Replace('__WEB_ROOT__',((Join-Path $dest 'web').Replace('\','/')))
    $conf | Set-Content -Encoding ASCII (Join-Path $nginxDir 'conf\portal.conf')
    $exe = $state.nginx_application
    $nginxPrefix = $nginxDir.Replace('\','/') + '/'
    Native $exe @('-t','-p',$nginxPrefix,'-c','conf/portal.conf')
    $nssm = Join-Path $dest 'runtime\nssm.exe'
    Native $nssm @('install',[string]$cfg.service_name,$exe)
    Native $nssm @('set',[string]$cfg.service_name,'AppDirectory',$nginxDir)
    Native $nssm @('set',[string]$cfg.service_name,'AppParameters',"-p $nginxPrefix -c conf/portal.conf")
    Native $nssm @('set',[string]$cfg.service_name,'Start','SERVICE_AUTO_START')
    Native $nssm @('set',[string]$cfg.service_name,'AppStdout',(Join-Path $nginxDir 'logs\service-stdout.log'))
    Native $nssm @('set',[string]$cfg.service_name,'AppStderr',(Join-Path $nginxDir 'logs\service-stderr.log'))
    Native $nssm @('set',[string]$cfg.service_name,'AppExit','Default','Restart')
    New-NetFirewallRule -Name "${prefix}HTTP" -DisplayName "Learning portal HTTP ($port)" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port -Profile $profiles -RemoteAddress $cfg.firewall_remote_address -Program $exe | Out-Null
    if ($cfg.enable_hostname_discovery_rules) {
        New-NetFirewallRule -Name "${prefix}LLMNR" -DisplayName 'Learning portal hostname LLMNR' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 5355 -Profile $profiles -RemoteAddress $cfg.firewall_remote_address | Out-Null
        New-NetFirewallRule -Name "${prefix}NetBIOS" -DisplayName 'Learning portal hostname NetBIOS' -Direction Inbound -Action Allow -Protocol UDP -LocalPort 137 -Profile $profiles -RemoteAddress $cfg.firewall_remote_address | Out-Null
    }
    Start-Service -Name $cfg.service_name
    $suffix = if ($port -eq 80) { '' } else { ":$port" }
    $healthy = $false
    for ($i=0; $i -lt 15; $i++) {
        try {
            $response = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1${suffix}/catalog.json" -TimeoutSec 3
            $body = $response.Content | ConvertFrom-Json
            if ((Get-Service $cfg.service_name).Status -eq 'Running' -and $body.schema_version -eq 1) { $healthy=$true; break }
        } catch { Start-Sleep -Seconds 1 }
    }
    if (!$healthy) { throw 'Service or local catalogue HTTP check failed. Inspect runtime\nginx\logs.' }
    $state.status='running'; Save-State
    Write-Host "SUCCESS: service is running and its catalogue is reachable. Local URL: http://localhost${suffix}/"
    Write-Host 'IPv4 addresses: choose the address on the school network, not a VPN/virtual adapter.'
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } | Select-Object InterfaceAlias,IPAddress | Format-Table
    if ($ResultPath) { @{ success=$true; install_directory=$dest; service_name=[string]$cfg.service_name; port=$port; local_url="http://localhost${suffix}/" } | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $ResultPath }
    Write-Host 'Check access from a school device using the server IP address.'
    exit 0
} catch {
    if ($ResultPath) { @{ success=$false; message=[string]$_; install_directory=[string]$dest } | ConvertTo-Json | Set-Content -Encoding UTF8 -LiteralPath $ResultPath }
    Write-Error "Installation stopped: $_" -ErrorAction Continue
    if ($null -eq $state) { Write-Host 'Stopped before installation changes were made.' } else { Write-Host 'Partial files/services may remain. Inspect installation.json and logs; uninstall preserves files by default.' }
    exit 1
}
