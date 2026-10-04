# Offline Learning Portal v1.1.0

Version 1.1.0 adds interactive Windows installation and removal to the local NGINX/NSSM portal.

## Installation

- Coloured buttons for installing, checking/selecting a free port, opening the portal and copying a device link.
- Administrator elevation, a responsive parent window, an activity indicator and background runner output.
- The chosen destination and port are saved for installation. The runner rechecks the port.
- Optional confirmed IIS W3SVC stopping when a running IIS port-80 binding can be associated with the listener. Setup rechecks port release and restores IIS if the port remains occupied. IIS startup settings and bindings are not changed.
- IP-address-and-port client links. Computer renaming and hostname-discovery firewall rules are disabled.

## Removal

- Keep files, Delete everything and Cancel buttons. Destructive removal requires a separate confirmation.
- Ownership/root/NGINX-path checks and a whitelist of portal firewall-rule names. An existing service must point to the owned executable.
- A removal runner, helper, result file and logs outside the installation folder, supporting full deletion while the window remains open.
- Service removal precedes firewall removal and optional directory deletion. Keep files updates the ownership record. Errors are not reported as successful completion.
- Uninstall does not restore or reconfigure IIS automatically.

## Validation

The project owner confirmed that all testing passed on their Windows PC on 4 October 2026. Detailed individual output, Windows build and hardware details were not supplied with that confirmation.

Preparation checks passed: seven PowerShell files parsed under PowerShell 7.4.6 on Linux; ten mocked port/IIS assertions; six catalogue tests; six mocked removal-engine tests; JSON parsing; PDF layout inspection; ZIP integrity and internal checksums. These preparation tests remain distinct from owner-reported Windows acceptance. Optional Kiwix/reverse-proxy execution is outside the recorded baseline checks.

The bundled NGINX/NSSM executable bytes and resource catalogue baseline are retained. Guides, metadata and technical records were updated for v1.1.0. Original project files use MIT; retain third-party notices.

GitHub release: https://github.com/tirtharaj84/offline-learning-portal/releases/tag/v1.1.0
Zenodo version DOI: https://doi.org/10.5281/zenodo.23131009
Creator: Tirtharaj Dhungana — tirtharajdhungana84@gmail.com.
