# Operate and troubleshoot

The installed folder defaults to C:\LearningPortal. Edit resources there after installation: changing the extracted source package does not change the running copy.

## Service and logs
Inspect OfflineLearningPortal in services.msc. Its startup type is Automatic; NSSM restarts the wrapped application after exit. Logs are in runtime/nginx/logs, including access/error and service stdout/stderr files. Monitor disk use and arrange log rotation as part of ongoing administration; unlimited log storage is not appropriate for a long-running deployment.

If setup fails, it leaves owned files and installation.json for diagnosis rather than reporting success. Read the error and logs. If failure occurred before scripts were copied, run the package's scripts/Uninstall-Portal.ps1 copied into the partial installation's scripts folder, or have an administrator inspect and remove only the recorded service/rules. Do not rerun the installer over a partial directory.

## Network access
HTTP inbound access defaults to Private and Domain profiles, from LocalSubnet only, and only for the installed nginx.exe. Check Get-NetConnectionProfile when local access works but LAN access fails. Choose the correct school network policy; do not blindly classify an untrusted network as Private. Routed clients on other subnets require an administrator to adjust the scope deliberately. The installer offers Any as an alternative scope, which is broader.

Optional hostname rules allow UDP 5355 (LLMNR) and 137 (NetBIOS name service) within the same profile/subnet scope. They do not enable name resolution, configure DHCP/DNS, or guarantee hostname access on every device. Disable enable_hostname_discovery_rules when school policy requires DNS-only operation. Ask the network administrator for a DNS record if needed. Use a DHCP reservation or managed static address for stable IP access; this script does not set IP addressing. Windows computer names and DNS records must be unique.

Test http://localhost/, then the actual LAN IP, then the actual hostname. For custom ports include :PORT. If IP works but hostname fails, diagnose name resolution. If neither remote URL works, check service state, chosen adapter/IP, firewall profile/scope and client isolation on the wireless network.

portal-settings.json is used at installation time. Editing it later does not apply changes. Port or installation-path changes require coordinated configuration, service and firewall updates by the administrator; do not simply rerun setup.

## Backup
Copy web (including all metadata and catalogue), portal-settings.json, installation.json, docs and runtime/nginx/conf/portal.conf to a separate device. Also retain approved binary distributions and version/hash notes. Take a consistent copy when resources are not being edited. Restore into a reviewed new deployment; do not blindly reuse a manifest to claim ownership of another installation.

## Uninstall
Right-click the installed Uninstall.bat and run as administrator. Type REMOVE after reviewing the installation. Choose option 1 to stop/remove the recorded service and firewall rules while keeping resources, or option 2 to additionally delete the installed directory. Full deletion also requires DELETE confirmation. It verifies the service application path before removing it. It does not rename the computer back.

Only after backing up, an elevated PowerShell command can also remove the entire installed directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\LearningPortal\scripts\Uninstall-Portal.ps1 -DeleteFiles
```

This additionally requires typing DELETE. Adjust the path if configured differently. It is irreversible without your backup.
