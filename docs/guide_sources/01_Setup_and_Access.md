# Set up and access your portal

Offline Learning Portal v1.1.0 | Tirtharaj Dhungana | MIT

## A school library on your local network

Offline Learning Portal serves permitted local resources on the school network. This guide covers v1.1.0 installation and removal windows. The project owner confirmed Windows acceptance; technical preparation checks are documented separately.

### Before you begin

- Use a Windows computer with Windows PowerShell 5.1 and administrator permission. Back up school resources.
- Extract the complete ZIP. NGINX and NSSM are already included. 
- Setup uses a window with coloured buttons. Normal setup does not require editing portal-settings.json.
- Phones and computers use the server IP address and port. Computer renaming and hostname-discovery rules are disabled.

### Find the right file

| Item | What it does |
| --- | --- |
| Install.bat | Launches Windows installation |
| portal-settings.json | Sets destination, name, port and firewall scope |
| web/resources/ | Holds documents, media and local activities |
| Rebuild_Catalog.bat | Updates resource cards after changes |
| Uninstall.bat | Offers preserve-files or full-removal options |

The portal uses one NGINX service, normally named OfflineLearningPortal. Optional Kiwix remains a separate service; choose different ports for separate services.

## Install and share the IP link

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

### If port 80 is already used

Use available port keeps other services running. For IIS, open IIS Manager > Sites > the site > Bindings, edit its HTTP binding to a free port such as 8082, update its links/firewall access, and recheck port 80. Other servers have their own listening-port settings.

Stop IIS for port 80... requires confirmation and interrupts IIS web publishing. It is temporary: IIS may reclaim port 80 after a restart. Change the binding or use a different portal port for a lasting arrangement.

## Check the service, browser and removal

### 1. Read the current state in PowerShell

```
Get-Service OfflineLearningPortal
Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object {$_.IPAddress -notlike '127.*'} |
  Select-Object InterfaceAlias,IPAddress
Get-NetTCPConnection -State Listen |
  Where-Object LocalPort -eq 80
```

Expected: service status Running and a listener on your configured port. Choose the IP of the school Wi-Fi/Ethernet adapter, not a VPN or virtual adapter. With example IP 192.168.1.25, open http://192.168.1.25/ from a learner phone. Replace it with your actual IP; add :8080 if that is your chosen port. Substitute your configured service name and port in the commands when different.

### 2. Test restart and a resource

Restart Windows. Open the portal without manually starting a service. Open a guide, use search, then add the worked example in Guide 02. Disconnect internet while keeping the school LAN connected and check again. Localhost works but a phone fails: check network profile, firewall scope and Wi-Fi client isolation.

### 3. Back up and uninstall

Back up web, portal-settings.json, installation.json and runtime/nginx/conf/portal.conf outside the installed folder. Open the installed Uninstall.bat and approve administrator access. Keep files removes the portal service/rules and retains resources. Delete everything also deletes the owned installation folder after a separate confirmation. Cancel starts no removal. Optional Kiwix has separate removal steps in Guide 03.

If an old page remains visible, try an explicit http:// URL in a private window and check the listener output above. An old cached page is not evidence that a server is running. Retain logs and installation.json when troubleshooting a failed installation.

### Evidence and references

The owner confirmed that Windows testing of the interactive tools passed on their PC. Detailed individual logs were not supplied with that confirmation. See docs/VALIDATION.md and docs/INTERACTIVE_SETUP_TEST.md for the record and reproducible checks.

## 4. Find your way around the installed portal

### Open the right folder

Press Windows+E to open File Explorer. Click its address bar, type C:\LearningPortal and press Enter. This is the installed copy that learners access. If you chose another install directory, substitute it throughout these manuals. Keep the extracted ZIP as a source copy; changing that copy does not update the running portal.

```
C:\LearningPortal\web\index.html       Portal homepage
C:\LearningPortal\web\styles.css       Homepage appearance
C:\LearningPortal\web\app.js           Main catalogue display
C:\LearningPortal\web\catalog.json     Generated resource list
C:\LearningPortal\web\resources\       Your learning content
C:\LearningPortal\Rebuild_Catalog.bat   Rebuild resource list
```

### Understand a browser address

The Windows path C:\LearningPortal\web\resources\Activities\lesson-starter\index.html becomes http://localhost/resources/Activities/lesson-starter/index.html on the server. web is the server document root and is omitted from the URL. On a learner device replace localhost with the server IP address. A browser URL uses forward slashes; a Windows path normally uses backslashes.

### Before editing

- Make a dated backup of web on another drive or device. Do not put your only backup inside a folder you may uninstall.
- Enable filename extensions in Explorer: View > Show > File name extensions on Windows 11; View > File name extensions on Windows 10. Menu wording can vary.
- For a text file, right-click > Open with > Notepad. On newer Windows, Show more options may be needed. Save as UTF-8 and All Files when creating a file.
- Refresh the browser after saving. A content edit does not need service reinstallation. Changes to generated catalog.json will be overwritten by the next rebuild.

### Which guide next?

Guide 02 builds a fresh local lesson using HTML, CSS and JavaScript, then adds media and optional Python. Guide 03 adds an independent Kiwix server and explains downloading its software and ZIM files. Neither requires the author's earlier portal code. Work through one page at a time and check the stated result before continuing.

