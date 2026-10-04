#requires -Version 5.1
param([string]$InstallRoot)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
if (!$InstallRoot) { $InstallRoot = Split-Path $PSScriptRoot -Parent }
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Start-Process -FilePath "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -Verb RunAs -ArgumentList @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',('"'+$PSCommandPath+'"'),'-InstallRoot',('"'+$InstallRoot+'"')) -ErrorAction Stop | Out-Null
        exit 0
    } catch { [Windows.Forms.MessageBox]::Show('Administrator approval was cancelled. No uninstall operation was started.','Uninstall cancelled') | Out-Null; exit 1 }
}
. (Join-Path $PSScriptRoot 'Uninstall-Helpers.ps1')
try { $state = Get-PortalRemovalState $InstallRoot }
catch { [Windows.Forms.MessageBox]::Show([string]$_,'Cannot uninstall this folder') | Out-Null; exit 1 }
$root = [string]$state.install_directory
# The coordinator must not retain the installation as its current directory.
Set-Location ([IO.Path]::GetTempPath())
$script:worker = $null
$script:finished = $false
$form = New-Object Windows.Forms.Form
$form.Text = 'Offline Learning Portal - uninstall'
$form.Size = New-Object Drawing.Size(780,590)
$form.MinimumSize = New-Object Drawing.Size(700,500)
$form.StartPosition = 'CenterScreen'
$form.AutoScaleMode = [Windows.Forms.AutoScaleMode]::Dpi
$form.Font = New-Object Drawing.Font('Segoe UI',10)
$form.BackColor = [Drawing.Color]::FromArgb(245,248,251)
$layout = New-Object Windows.Forms.TableLayoutPanel
$layout.Dock='Fill';$layout.Padding=New-Object Windows.Forms.Padding(22)
$layout.ColumnCount=1;$layout.RowCount=6
foreach ($height in @(60,95,80,65,45,0)) {
    $style=New-Object Windows.Forms.RowStyle
    if ($height -eq 0) {$style.SizeType='Percent';$style.Height=100} else {$style.SizeType='Absolute';$style.Height=$height}
    $layout.RowStyles.Add($style) | Out-Null
}
$form.Controls.Add($layout)
function Label([string]$Text) {
    $c=New-Object Windows.Forms.Label;$c.Text=$Text;$c.Dock='Fill';$c.TextAlign='MiddleLeft';$c.AutoEllipsis=$true;return $c
}
function Button([string]$Text,[string]$Color) {
    $c=New-Object Windows.Forms.Button;$c.Text=$Text;$c.AutoSize=$true;$c.Height=42
    $c.Padding=New-Object Windows.Forms.Padding(12,6,12,6);$c.Margin=New-Object Windows.Forms.Padding(0,4,12,4)
    $c.FlatStyle='Flat';$c.FlatAppearance.BorderSize=0;$c.BackColor=[Drawing.ColorTranslator]::FromHtml($Color);$c.ForeColor=[Drawing.Color]::White;return $c
}
$title=Label 'Remove this portal installation';$title.Font=New-Object Drawing.Font('Segoe UI',19,[Drawing.FontStyle]::Bold)
$title.ForeColor=[Drawing.Color]::FromArgb(25,59,87);$layout.Controls.Add($title,0,0)
$details=Label ("Folder: $root`r`nService: $($state.service_name)`r`nOnly the owned portal service and recorded firewall rules will be removed.")
$layout.Controls.Add($details,0,1)
$explain=Label "Keep files: remove the service and rules; retain every installed file and resource.`r`nDelete everything: also permanently delete this entire installation folder.`r`nCancel: close without removing anything."
$layout.Controls.Add($explain,0,2)
$actions=New-Object Windows.Forms.FlowLayoutPanel;$actions.Dock='Fill';$actions.WrapContents=$false
$keep=Button 'Keep files' '#16776B';$delete=Button 'Delete everything' '#B83A3A';$cancel=Button 'Cancel' '#657583'
$actions.Controls.AddRange(@($keep,$delete,$cancel));$layout.Controls.Add($actions,0,3)
$status=Label 'Back up school resources before choosing Delete everything.';$layout.Controls.Add($status,0,4)
$resultBox=New-Object Windows.Forms.TextBox;$resultBox.Multiline=$true;$resultBox.ReadOnly=$true;$resultBox.ScrollBars='Vertical';$resultBox.Dock='Fill';$resultBox.TabStop=$false
$resultBox.Font=New-Object Drawing.Font('Consolas',9);$resultBox.BackColor=[Drawing.Color]::White;$layout.Controls.Add($resultBox,0,5)
$timer=New-Object Windows.Forms.Timer;$timer.Interval=300
function Start-Removal([bool]$DeleteAll) {
    try {
        $question=if($DeleteAll){"Permanently delete ALL files and resources in $root after removing the portal service and rules? This cannot be undone without your backup."}else{"Remove the portal service and its firewall rules, keeping ALL files and resources in $root?"}
        if([Windows.Forms.MessageBox]::Show($question,'Confirm portal removal','YesNo','Warning','Button2') -ne 'Yes'){return}
        # Keep the runner, helper, results and logs outside the folder being deleted.
        $script:jobDirectory=Join-Path ([IO.Path]::GetTempPath()) ('PortalUninstall-'+[guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $script:jobDirectory | Out-Null
        foreach($file in @('Uninstall-Portal.ps1','Uninstall-Helpers.ps1')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $file) -Destination $script:jobDirectory -ErrorAction Stop}
        $runner=Join-Path $script:jobDirectory 'Uninstall-Portal.ps1'
        $script:resultFile=Join-Path $script:jobDirectory 'result.json'
        $script:logPath=Join-Path $script:jobDirectory 'uninstall.log'
        $info=New-Object Diagnostics.ProcessStartInfo
        $info.FileName="$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
        $info.Arguments='-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "'+$runner+'" -Unattended -InstallRoot "'+$root+'" -ResultPath "'+$script:resultFile+'"'
        if($DeleteAll){$info.Arguments+=' -DeleteFiles'}
        $info.WorkingDirectory=$script:jobDirectory;$info.UseShellExecute=$false;$info.CreateNoWindow=$true
        $info.RedirectStandardOutput=$true;$info.RedirectStandardError=$true
        $script:worker=New-Object Diagnostics.Process;$script:worker.StartInfo=$info;$script:worker.Start() | Out-Null
        $script:stdout=$script:worker.StandardOutput.ReadToEndAsync();$script:stderr=$script:worker.StandardError.ReadToEndAsync()
        foreach($control in @($keep,$delete,$cancel)){$control.Enabled=$false}
        $status.Text='Removing the portal. Please wait...';$timer.Start()
    } catch {
        if($script:worker){$script:worker.Dispose();$script:worker=$null}
        $status.Text='Removal could not start. No successful result was recorded.'
        $resultBox.AppendText("$_`r`n");$cancel.Enabled=$true
    }
}
$keep.Add_Click({Start-Removal $false})
$delete.Add_Click({Start-Removal $true})
$cancel.Add_Click({$form.Close()})
$timer.Add_Tick({
    if(!$script:worker -or !$script:worker.HasExited -or !$script:stdout.IsCompleted -or !$script:stderr.IsCompleted){return}
    $timer.Stop()
    try {
        $text=($script:stdout.Result+"`r`n"+$script:stderr.Result).Replace([string][char]0,'')
        $text | Set-Content -Encoding UTF8 -LiteralPath $script:logPath
        $result=Get-Content -Raw -LiteralPath $script:resultFile | ConvertFrom-Json
        if($script:worker.ExitCode -ne 0 -or !$result.success){throw $result.message}
        $script:finished=$true
        $status.Text=if($result.deleted){'Portal removed. The installed folder was deleted.'}else{'Portal service and rules removed. All files and resources were kept.'}
        # Use the verified result for the visible message. Native process output
        # can contain incompatible encodings; preserve it in the diagnostic log.
        $summary=if($result.deleted){
            "DELETE EVERYTHING completed successfully.`r`n`r`nThe portal service and its recorded firewall rules were removed.`r`nThe installation folder and all files and resources inside it were deleted.`r`nFolder: $root"
        }else{
            "KEEP FILES completed successfully.`r`n`r`nThe portal service and its recorded firewall rules were removed.`r`nAll installed files and school resources were preserved.`r`nFolder: $root"
        }
        $resultBox.Clear()
        $resultBox.Lines=[string[]](($summary+"`r`n`r`nDiagnostic log: $script:logPath") -split "`r?`n")
        $resultBox.SelectionStart=0
        $resultBox.SelectionLength=0
        $resultBox.ScrollToCaret()
        $status.ForeColor=[Drawing.Color]::FromArgb(22,119,107)
    } catch {$status.Text='Removal did not complete. See the error below.';$status.ForeColor=[Drawing.Color]::Firebrick;$resultBox.Text="Removal did not complete.`r`n$_`r`n`r`nProcess output:`r`n$text`r`nDiagnostic log: $script:logPath"}
    finally {$script:worker.Dispose();$script:worker=$null;$cancel.Enabled=$true;$cancel.Text='Close'}
})
$form.Add_FormClosing({param($sender,$eventArgs)
    if($script:worker -and !$script:worker.HasExited){$eventArgs.Cancel=$true;[Windows.Forms.MessageBox]::Show('Wait for removal to finish before closing.','Removal in progress') | Out-Null}
})
try{[void]$form.ShowDialog()}finally{$timer.Dispose();$form.Dispose()}
