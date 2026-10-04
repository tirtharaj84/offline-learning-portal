# Verify ownership before any service, firewall or file removal.
function Get-PortalRemovalState([string]$InstallRoot) {
    $root = [IO.Path]::GetFullPath($InstallRoot).TrimEnd([char[]]@('\','/'))
    $driveRoot = [IO.Path]::GetPathRoot($root).TrimEnd([char[]]@('\','/'))
    if ($root -eq $driveRoot) { throw 'A drive root cannot be removed.' }
    $manifest = Join-Path $root 'installation.json'
    if (!(Test-Path -LiteralPath $manifest -PathType Leaf)) { throw 'Run Uninstall.bat from the installed portal folder. The ownership record installation.json is required.' }
    $state = Get-Content -Raw -LiteralPath $manifest -ErrorAction Stop | ConvertFrom-Json
    $recordedRoot = [IO.Path]::GetFullPath([string]$state.install_directory).TrimEnd([char[]]@('\','/'))
    if ($recordedRoot -ine $root) { throw 'The ownership record does not match this folder. No removal performed.' }
    if ($state.service_name -notmatch '^[A-Za-z][A-Za-z0-9_]{0,63}$') { throw 'The ownership record contains an invalid service name.' }
    $expectedApp = Join-Path $root 'runtime/nginx/nginx.exe'
    if ([IO.Path]::GetFullPath([string]$state.nginx_application) -ine [IO.Path]::GetFullPath($expectedApp)) { throw 'The recorded NGINX path is outside the expected runtime location.' }
    $allowedRules = @("$($state.service_name)-HTTP", "$($state.service_name)-LLMNR", "$($state.service_name)-NetBIOS")
    foreach ($rule in @($state.firewall_names)) {
        if ($rule -notin $allowedRules) { throw 'The ownership record contains an unrelated firewall rule. No removal performed.' }
    }
    $service = Get-Service -Name $state.service_name -ErrorAction SilentlyContinue
    if ($service) {
        $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$($state.service_name)\Parameters"
        $app = (Get-ItemProperty -LiteralPath $key -Name Application -ErrorAction Stop).Application
        if ([IO.Path]::GetFullPath([string]$app) -ine [IO.Path]::GetFullPath($expectedApp)) { throw 'The service points to a different application. No removal performed.' }
    }
    return $state
}
