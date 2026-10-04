# Offline Learning Portal - v1.1.0

The project owner confirmed that testing of the interactive installation and removal tools passed on their Windows PC. The technical record distinguishes this report from portable preparation checks. See `docs/VALIDATION.md`.

NGINX serves a local resource catalogue and files over the school LAN. NSSM runs it as a Windows service. The setup window provides folder/port controls, an activity indicator, installation output, a local Open portal button and a Copy device link button. Phones and computers use the server's IP address and selected port. Computer renaming and hostname discovery are disabled.

## Install

Use Windows with Windows PowerShell 5.1 and administrator permission. Keep school resources backed up.

### 1. Extract the ZIP

Right-click the ZIP and choose Extract All. Open the extracted portal folder.

### 2. Open setup

Double-click Install.bat and approve the Windows administrator prompt. A setup window opens; you do not need to edit JSON for the normal settings.

### 3. Choose the folder and port

Keep the displayed folder and port, or choose another. Click Check port. If the port is occupied, click Use available port to select a free alternative. The installer also rechecks the port before installing.

### 4. Install

Click Install portal. Wait for Installed successfully. Setup configures NGINX, the Windows service and the inbound HTTP firewall rule. It does not rename the computer.

### 5. Open and share the IP link

Click Open portal to check it on the server. Choose the school Wi-Fi or Ethernet address from LAN address, then click Copy device link. Open that link on phones or computers connected to the same school network. The port is included automatically when needed.

Check the portal once after restarting Windows to confirm automatic service startup. This is a validation check, not another setup step.

## If another service needs port 80

The simplest arrangement is to keep that service running and choose another portal port, such as 8080. The setup window displays the complete IP-and-port link.

To move an IIS site instead, open **IIS Manager > Sites > the site > Bindings**, select its HTTP binding, choose **Edit**, and change the port to a free value such as 8082. Repeat for other HTTP bindings still using port 80. Update that site's links and any firewall rule needed for its clients, then use **Check port** in portal setup. Keep port 8081 free if you plan to use it for the optional Kiwix server. For another web server, change its listening port in that application's configuration and restart that service according to its own instructions.

**Stop IIS for port 80...** is an optional temporary action. It requires a running IIS HTTP binding associated with the occupied port and a separate confirmation. It interrupts IIS web publishing, checks whether port 80 became free, and restores IIS if the port remains occupied. It does not change IIS bindings or startup settings, stop the shared HTTP service, or disable WAS. IIS may reclaim port 80 after a Windows restart; change the binding or use another portal port for a lasting arrangement. If setup is cancelled before successful installation, it attempts to restore IIS. After a successful installation, restore IIS only after resolving the binding conflict; an administrator can use `Start-Service W3SVC`.

## Uninstall

Open `Uninstall.bat` from the installed portal folder and approve administrator access. The window shows the owned folder and service.

- **Keep files:** remove the portal service and recorded firewall rules; retain the installed files and school resources. The ownership record is updated to show removal.
- **Delete everything:** remove the same service/rules and permanently delete the entire owned installation folder. Review the folder and confirm deletion only after backing up.
- **Cancel:** close without starting removal.

Removal runs from a temporary folder outside the installation. Results and logs remain there even after full deletion. Both window and runner verify ownership; the runner also checks that any existing service points to the installed NGINX executable. Uninstall does not restore or reconfigure IIS. If setup temporarily stopped IIS, resolve its binding conflict before an administrator restores it.

## Resource management

Copy permitted resources into `web/resources` and run `Rebuild_Catalog.bat` with Python 3 installed. Python is not needed for browsing or installation. Supported catalogue formats are PDF, MP3, WAV, M4A, OGG, MP4, WEBM, HTML and HTM. HTML entry pages need metadata sidecars and complete local assets. See `docs/TAILORING.md`.

There is no browser upload/administration panel, learner account system or progress tracking. Kiwix is a separately configured optional service. Guide 1 covers setup and removal; Guides 2 and 3 cover resource activities and optional Kiwix configuration.

## Configuration and records

Normal settings come from `portal-settings.json`; the window lets you change destination and port for this installation. The selected settings are saved in the installed folder. Advanced service and firewall settings can be edited before launching setup. The window lists the actual profiles and remote-address scope. Existing installation folders, service names and named firewall rules are not overwritten. Failures retain an ownership record and installation output for troubleshooting.

See `docs/VALIDATION.md` and `docs/INTERACTIVE_SETUP_TEST.md` for the recorded checks and reproducible Windows procedures. The catalogue generator and bundled executable bytes are retained from the baseline.

## Licence and creator

Original files use MIT; keep `LICENSE.txt`, `LICENSE_STATUS.md`, `THIRD_PARTY_NOTICES.md` and vendor notices. Tirtharaj Dhungana: tirtharajdhungana84@gmail.com. AI assistance is recorded in `ACKNOWLEDGEMENTS.md`.

Repository: https://github.com/tirtharaj84/offline-learning-portal

Published v1.0.0 baseline DOI: https://doi.org/10.5281/zenodo.23120387. That DOI identifies the earlier v1.0.0 release.

The package includes SHA256SUMS.txt for all distributed files except the manifest itself.

Version 1.1.0 release: https://github.com/tirtharaj84/offline-learning-portal/releases/tag/v1.1.0
