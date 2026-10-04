#requires -Version 5.1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Start-Process -FilePath "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -Verb RunAs -ArgumentList @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',('"' + $PSCommandPath + '"')) -ErrorAction Stop | Out-Null
        exit 0
    } catch {
        [Windows.Forms.MessageBox]::Show('Setup needs administrator approval to install the service and firewall rule. You can run Install.bat again when ready.', 'Setup cancelled') | Out-Null
        exit 1
    }
}
$package = Split-Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot 'Setup-Helpers.ps1')
try { $cfg = Get-Content -Raw -LiteralPath (Join-Path $package 'portal-settings.json') | ConvertFrom-Json }
catch { [Windows.Forms.MessageBox]::Show("Cannot read portal-settings.json: $_", 'Setup error') | Out-Null; exit 1 }
$script:worker = $null
$script:iisStopped = $false
$script:installed = $false
$script:jobDirectory = $null
$script:localUrl = ''
$script:logPath = ''
$form = New-Object Windows.Forms.Form
$form.Text = 'Offline Learning Portal - setup v1.1.0'
$form.Size = New-Object Drawing.Size(820,720)
$form.MinimumSize = New-Object Drawing.Size(760,620)
$form.StartPosition = 'CenterScreen'
$form.AutoScaleMode = [Windows.Forms.AutoScaleMode]::Dpi
$form.Font = New-Object Drawing.Font('Segoe UI',10)
$form.BackColor = [Drawing.Color]::FromArgb(245,248,251)
$layout = New-Object Windows.Forms.TableLayoutPanel
$layout.Dock = 'Fill'; $layout.Padding = New-Object Windows.Forms.Padding(22)
$layout.ColumnCount = 1; $layout.RowCount = 10
foreach ($height in @(65,58,48,48,65,50,0,55,55,45)) {
    $style = New-Object Windows.Forms.RowStyle
    if ($height -eq 0) { $style.SizeType='Percent'; $style.Height=100 } else { $style.SizeType='Absolute'; $style.Height=$height }
    $layout.RowStyles.Add($style) | Out-Null
}
$form.Controls.Add($layout)
function Label([string]$Text) {
    $control = New-Object Windows.Forms.Label
    $control.Text = $Text; $control.Dock='Fill'; $control.TextAlign='MiddleLeft'
    $control.AutoEllipsis = $true
    return $control
}
function Button([string]$Text,[string]$Color) {
    $control = New-Object Windows.Forms.Button
    $control.Text=$Text; $control.AutoSize=$true; $control.Height=38
    $control.Padding=New-Object Windows.Forms.Padding(10,5,10,5)
    $control.FlatStyle='Flat'; $control.FlatAppearance.BorderSize=0
    $control.BackColor=[Drawing.ColorTranslator]::FromHtml($Color)
    $control.ForeColor=[Drawing.Color]::White; $control.Margin=New-Object Windows.Forms.Padding(0,2,8,2)
    return $control
}
function Row {
    $panel = New-Object Windows.Forms.FlowLayoutPanel
    $panel.Dock='Fill'; $panel.WrapContents=$false
    return $panel
}
$title=Label 'Install your school learning portal'
$title.Font=New-Object Drawing.Font('Segoe UI',19,[Drawing.FontStyle]::Bold)
$title.ForeColor=[Drawing.Color]::FromArgb(25,59,87); $layout.Controls.Add($title,0,0)
$summary=Label ("Choose the folder and port, then click Install. Service: $($cfg.service_name).`r`nFirewall: $(@($cfg.firewall_profiles) -join ', ') / $($cfg.firewall_remote_address). Devices use the server IP address.")
$layout.Controls.Add($summary,0,1)
$folderRow=Row; $folderLabel=Label 'Install folder'; $folderLabel.Dock='None'; $folderLabel.Width=100
$destination=New-Object Windows.Forms.TextBox; $destination.Text=[string]$cfg.install_directory; $destination.Width=610
$folderRow.Controls.AddRange(@($folderLabel,$destination)); $layout.Controls.Add($folderRow,0,2)
$portRow=Row; $portLabel=Label 'Portal port'; $portLabel.Dock='None'; $portLabel.Width=100
$port=New-Object Windows.Forms.NumericUpDown; $port.Minimum=1; $port.Maximum=65535; $port.Value=[int]$cfg.http_port; $port.Width=90
$check=Button 'Check port' '#285C87'; $suggest=Button 'Use available port' '#16776B'
$portRow.Controls.AddRange(@($portLabel,$port,$check,$suggest)); $layout.Controls.Add($portRow,0,3)
$status=Label 'Click Check port to check availability.'
$statusPanel=New-Object Windows.Forms.Panel; $statusPanel.Dock='Fill'
$progress=New-Object Windows.Forms.ProgressBar; $progress.Dock='Bottom'; $progress.Height=8; $progress.Style='Marquee'; $progress.Visible=$false
$statusPanel.Controls.Add($status); $statusPanel.Controls.Add($progress); $layout.Controls.Add($statusPanel,0,4)
$actionRow=Row
$install=Button 'Install portal' '#16776B'; $iis=Button 'Stop IIS for port 80...' '#A96611'; $close=Button 'Close' '#657583'
$actionRow.Controls.AddRange(@($install,$iis,$close)); $layout.Controls.Add($actionRow,0,5)
$log=New-Object Windows.Forms.TextBox; $log.Multiline=$true; $log.ReadOnly=$true; $log.ScrollBars='Vertical'; $log.Dock='Fill'
$log.Font=New-Object Drawing.Font('Consolas',9); $log.BackColor=[Drawing.Color]::White
$log.Text="Offline Learning Portal v1.1.0 setup.`r`nA free alternative port keeps existing web services available."
$layout.Controls.Add($log,0,6)
$addressRow=Row; $addressLabel=Label 'LAN address'; $addressLabel.Dock='None'; $addressLabel.Width=100
$addresses=New-Object Windows.Forms.ComboBox; $addresses.DropDownStyle='DropDownList'; $addresses.Width=480
$addressRow.Controls.AddRange(@($addressLabel,$addresses)); $layout.Controls.Add($addressRow,0,7)
$urlBox=New-Object Windows.Forms.TextBox; $urlBox.ReadOnly=$true; $urlBox.Dock='Fill'; $layout.Controls.Add($urlBox,0,8)
$finishRow=Row; $open=Button 'Open portal' '#285C87'; $copy=Button 'Copy device link' '#16776B'; $open.Enabled=$false; $copy.Enabled=$false
$finishRow.Controls.AddRange(@($open,$copy)); $layout.Controls.Add($finishRow,0,9)
function Add-Log([string]$Message) { $log.AppendText("`r`n$Message") }
function Refresh-Port {
    try {
        $listening=@(Get-PortalPortListeners ([int]$port.Value))
        if (!$listening.Count) {
            $status.Text="Port $($port.Value) is available. Click Install portal."
            $status.ForeColor=[Drawing.Color]::FromArgb(22,119,107)
        } else {
            $owners=($listening | Select-Object -ExpandProperty OwningProcess -Unique) -join ', '
            $status.Text="Port $($port.Value) is occupied (process IDs: $owners). Choose Use available port, or inspect IIS."
            $status.ForeColor=[Drawing.Color]::FromArgb(155,90,10)
        }
        $iis.Enabled=([int]$port.Value -eq 80 -and $listening.Count -gt 0)
        $install.Enabled=(!$script:installed -and !$script:worker -and !$listening.Count)
    } catch { $status.Text="Cannot inspect ports: $_"; $install.Enabled=$false; $iis.Enabled=$false }
}
function Refresh-Urls {
    if (!$script:installed) { return }
    $suffix=if ([int]$port.Value -eq 80) { '' } else { ":$($port.Value)" }
    $script:localUrl="http://localhost$suffix/"
    if ($addresses.SelectedIndex -ge 0) {
        $entry=$script:lanEntries[$addresses.SelectedIndex]
        $urlBox.Text="http://$($entry.IPAddress)$suffix/"
        $copy.Enabled=$true
    } else { $urlBox.Text='No school-network IPv4 address found. Connect to the LAN, then reopen or inspect the network settings.'; $copy.Enabled=$false }
}
function Restore-IisIfNeeded {
    if ($script:iisStopped -and !$script:installed) {
        # Do not compete with a partially installed running portal.
        $portalService=Get-Service -Name $cfg.service_name -ErrorAction SilentlyContinue
        if ($portalService -and $portalService.Status -eq 'Running') {
            Add-Log 'IIS remains stopped because the portal service is running. Inspect the partial installation before restoring IIS.'
            return
        }
        try { Start-Service W3SVC -ErrorAction Stop; $script:iisStopped=$false; Add-Log 'IIS restored because setup did not complete.' }
        catch { Add-Log "IIS restore failed: $_. Ask the administrator to start W3SVC." }
    }
}
$check.Add_Click({ Refresh-Port })
$suggest.Add_Click({ try { $port.Value=Get-PortalFreePort; Refresh-Port } catch { [Windows.Forms.MessageBox]::Show([string]$_,'Port check') | Out-Null } })
$port.Add_ValueChanged({ if (!$script:worker -and !$script:installed) { Refresh-Port } })
$iis.Add_Click({
    try {
        $sites=@(Get-PortalIisSites)
        if (!$sites.Count) { throw 'Running IIS HTTP sites could not be associated with port 80. Use another portal port. IIS Management tools may be unavailable.' }
        $message="Stop IIS web publishing for these sites: $($sites -join ', ')? All IIS HTTP/HTTPS sites will be interrupted. This does not disable IIS startup; it may reclaim port 80 after a restart. For a lasting arrangement, move the IIS HTTP bindings to another free port or use another portal port."
        if ([Windows.Forms.MessageBox]::Show($message,'Confirm IIS interruption','YesNo','Warning') -ne 'Yes') { return }
        Stop-PortalIisForPort80; $script:iisStopped=$true
        Add-Log 'IIS W3SVC stopped at your request. Startup settings and bindings were not changed. Use Start-Service W3SVC after resolving the conflict to restore IIS.'
        Refresh-Port
    } catch { [Windows.Forms.MessageBox]::Show([string]$_,'IIS / port check') | Out-Null; Refresh-Port }
})
$install.Add_Click({
    try {
        if (@(Get-PortalPortListeners ([int]$port.Value)).Count) { throw 'The selected port is now occupied. Choose another port.' }
        $chosenDestination=$destination.Text.Trim()
        if ($chosenDestination -notmatch '^[A-Za-z]:\\(?:[A-Za-z0-9_-]+\\)*[A-Za-z0-9_-]+$') { throw 'Use a new install folder such as C:\LearningPortal. Spaces are not supported in the install folder.' }
        if (Test-Path -LiteralPath $chosenDestination) { throw 'This installation folder already exists. Choose a different new folder or review the existing installation.' }
        $cfg.install_directory=$chosenDestination; $cfg.http_port=[int]$port.Value
        $cfg.offer_computer_rename=$false; $cfg.enable_hostname_discovery_rules=$false
        $cfg | Add-Member -NotePropertyName iis_service_stopped_by_setup -NotePropertyValue $script:iisStopped -Force
        $script:jobDirectory=Join-Path ([IO.Path]::GetTempPath()) ('PortalSetup-'+[guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $script:jobDirectory | Out-Null
        $configFile=Join-Path $script:jobDirectory 'settings.json'; $script:resultFile=Join-Path $script:jobDirectory 'result.json'
        $cfg | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 -LiteralPath $configFile
        $script:logPath=Join-Path $script:jobDirectory 'setup.log'
        $startInfo=New-Object Diagnostics.ProcessStartInfo
        $startInfo.FileName="$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
        $engine=Join-Path $PSScriptRoot 'Install-Portal.ps1'
        $startInfo.Arguments='-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "'+$engine+'" -Unattended -ConfigPath "'+$configFile+'" -ResultPath "'+$script:resultFile+'"'
        $startInfo.UseShellExecute=$false; $startInfo.CreateNoWindow=$true
        $startInfo.RedirectStandardOutput=$true; $startInfo.RedirectStandardError=$true
        $script:worker=New-Object Diagnostics.Process; $script:worker.StartInfo=$startInfo
        $script:worker.Start() | Out-Null
        $script:stdout=$script:worker.StandardOutput.ReadToEndAsync(); $script:stderr=$script:worker.StandardError.ReadToEndAsync()
        foreach ($control in @($destination,$port,$check,$suggest,$install,$iis,$close)) { $control.Enabled=$false }
        $status.Text='Installing: copying files, configuring NGINX, service and firewall, then checking the catalogue...'
        Add-Log 'Installation started. Please wait; this window stays responsive. Completion output appears below.'
        $progress.Visible=$true
        $timer.Start()
    } catch { Restore-IisIfNeeded; [Windows.Forms.MessageBox]::Show([string]$_,'Setup could not start') | Out-Null; Refresh-Port }
})
$timer=New-Object Windows.Forms.Timer; $timer.Interval=300
$timer.Add_Tick({
    if (!$script:worker -or !$script:worker.HasExited -or !$script:stdout.IsCompleted -or !$script:stderr.IsCompleted) { return }
    $timer.Stop(); $progress.Visible=$false
    $outputText=$script:stdout.Result+"`r`n"+$script:stderr.Result
    $outputText | Set-Content -Encoding UTF8 -LiteralPath $script:logPath
    Add-Log $outputText
    try {
        $result=Get-Content -Raw -LiteralPath $script:resultFile | ConvertFrom-Json
        if ($script:worker.ExitCode -ne 0 -or !$result.success) { throw $result.message }
        $script:installed=$true; $status.Text='Installed successfully. Open the portal or copy the link for school devices.'
        $status.ForeColor=[Drawing.Color]::FromArgb(22,119,107)
        try { $script:lanEntries=@(Get-PortalLanAddresses) } catch { $script:lanEntries=@(); Add-Log "Portal installed; address lookup failed: $_" }
        foreach ($entry in $script:lanEntries) { $addresses.Items.Add("$($entry.InterfaceAlias): $($entry.IPAddress)") | Out-Null }
        if ($addresses.Items.Count) { $addresses.SelectedIndex=0 }
        $open.Enabled=$true; Refresh-Urls
        if ($script:iisStopped) { Add-Log 'IIS was stopped temporarily. Resolve its port binding before the next Windows restart.' }
    } catch {
        $status.Text='Setup did not complete. See the details below.'; $status.ForeColor=[Drawing.Color]::Firebrick
        Add-Log "$_`r`nSaved log: $script:logPath"
        Restore-IisIfNeeded
        # A partial destination may remain; do not overwrite it on retry.
        foreach ($control in @($destination,$port,$check,$suggest)) { $control.Enabled=$true }
    } finally { $script:worker.Dispose(); $script:worker=$null; $close.Enabled=$true; if (!$script:installed) { Refresh-Port } }
})
$addresses.Add_SelectedIndexChanged({ Refresh-Urls })
$open.Add_Click({ if ($script:localUrl) { Start-Process $script:localUrl } })
$copy.Add_Click({ if ($script:installed -and $copy.Enabled) { [Windows.Forms.Clipboard]::SetText($urlBox.Text); Add-Log 'Device link copied. Share it with devices on the school network.' } })
$close.Add_Click({ $form.Close() })
$form.Add_FormClosing({
    param($sender,$eventArgs)
    if ($script:worker -and !$script:worker.HasExited) { $eventArgs.Cancel=$true; [Windows.Forms.MessageBox]::Show('Wait for setup to finish before closing.','Installation in progress') | Out-Null; return }
    Restore-IisIfNeeded
})
Refresh-Port
try { [void]$form.ShowDialog() } finally { $timer.Dispose(); $form.Dispose() }
