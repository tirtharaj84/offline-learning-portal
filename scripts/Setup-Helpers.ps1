# Shared port checks for the Windows setup window. No changes occur on import.
function Get-PortalPortListeners([int]$Port) {
    @(Get-NetTCPConnection -State Listen -ErrorAction Stop | Where-Object LocalPort -eq $Port)
}
function Get-PortalFreePort {
    foreach ($portNumber in @(80) + @(8080..8099)) {
        if (@(Get-PortalPortListeners $portNumber).Count -eq 0) { return $portNumber }
    }
    throw 'No suggested port is free. Enter another port and click Check port.'
}
function Get-PortalIisSites {
    $service = Get-Service W3SVC -ErrorAction SilentlyContinue
    if (!$service -or $service.Status -ne 'Running') { return @() }
    $listeners = @(Get-PortalPortListeners 80)
    if (!$listeners.Count -or @($listeners | Where-Object OwningProcess -ne 4).Count) { return @() }
    # PID 4 is shared HTTP.sys: a running IIS HTTP binding is supporting evidence,
    # not proof that IIS is the only owner. Recheck the port after stopping W3SVC.
    Import-Module WebAdministration -ErrorAction Stop
    @(Get-Website | Where-Object {
        $_.State -eq 'Started' -and @($_.Bindings.Collection | Where-Object {
            $_.protocol -eq 'http' -and $_.bindingInformation -match ':80:'
        }).Count -gt 0
    } | ForEach-Object { [string]$_.Name })
}
function Stop-PortalIisForPort80 {
    if (@(Get-PortalIisSites).Count -eq 0) {
        throw 'Cannot associate port 80 with a running IIS site. Choose a different portal port.'
    }
    $stoppedByUs = $false
    try {
        Stop-Service -Name W3SVC -ErrorAction Stop
        $stoppedByUs = $true
        (Get-Service W3SVC).WaitForStatus('Stopped', [TimeSpan]::FromSeconds(30))
        for ($attempt = 0; $attempt -lt 10; $attempt++) {
            if (@(Get-PortalPortListeners 80).Count -eq 0) { return }
            Start-Sleep -Milliseconds 300
        }
        throw 'Port 80 is still occupied after stopping IIS. Another HTTP.sys application may be using it. Choose another portal port.'
    } catch {
        if ($stoppedByUs) {
            try { Start-Service W3SVC -ErrorAction Stop }
            catch { throw "IIS could not be restored. Ask an administrator to start W3SVC. Original operation failed: $_" }
        }
        throw
    }
}
function Get-PortalLanAddresses {
    @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop | Where-Object {
        $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' -and $_.AddressState -eq 'Preferred'
    } | Sort-Object InterfaceAlias, IPAddress)
}
