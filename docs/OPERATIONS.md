# Operations - v1.1.0

## Installed files and resources

The installed destination, normally C:\LearningPortal, is the live copy. Editing the extracted package does not update it. Resource changes need catalogue rebuilding and browser refresh, not service reinstallation.

## Service and network

The selected service uses automatic startup; NSSM restarts NGINX after application exit. NGINX logs are under runtime/nginx/logs. Use the actual LAN IPv4 address and configured port. Hostname discovery and computer renaming are disabled. The HTTP rule uses the configured profile/remote-address scope and NGINX program path. If local access succeeds but phone access fails, check the chosen adapter, firewall profile/scope and Wi-Fi client isolation. The installer does not assign a static IP or DHCP reservation.

For lasting port sharing, keep other services on their own ports. Move IIS HTTP bindings using IIS Manager > Sites > the site > Bindings > Edit; update existing-site links and permitted firewall access. Temporary W3SVC stopping can be reversed with Start-Service W3SVC after resolving bindings. Neither portal uninstall option restores IIS automatically.

## Failure records

Setup retains a partial owned destination and installation.json if it fails after creating files. The window shows process output. Installer and removal runner logs/results are held in uniquely named PortalSetup-* and PortalUninstall-* directories under the temporary folder. Save these records before cleaning temporary files. Do not rerun setup over a partial destination.

If a partial installation lacks removal scripts, copy Uninstall.bat and scripts/Uninstall-Portal-GUI.ps1, scripts/Uninstall-Portal.ps1 and scripts/Uninstall-Helpers.ps1 from this package into that partial destination with the same folder structure. Keep its installation.json unchanged; the removal tools verify it.

## Backup

Copy web, settings, installation.json, docs and runtime/nginx/conf/portal.conf to another device before destructive removal. Keep original binary notices and distributions. The backup must be outside the directory being deleted.

## Interactive removal

Run the installed Uninstall.bat and approve administrator access. Review the displayed folder and service.

- Keep files: after confirmation, stop/deregister the owned portal service and remove its recorded named firewall rules. Preserve files/resources and mark the ownership record uninstalled-files-preserved.
- Delete everything: after an explicit permanent-deletion confirmation, do the same and delete the entire owned directory. Only report successful deletion after confirming that the directory is absent.
- Cancel: close without initiating removal. Once a runner starts, closing is blocked until it finishes.

The coordinator uses a temporary working directory; the runner and helper are copied outside the installation to support deletion while the window remains open. Ownership checks run before the window and again in the runner. Mismatched service paths or unrelated rule names stop removal. On error, close the window, review the retained logs/state and resolve the problem before retrying.

The console runner remains available for administrator use and retains typed confirmations unless launched with its internal -Unattended switch by the confirmed GUI action. Do not use that internal switch to bypass the intended review.
