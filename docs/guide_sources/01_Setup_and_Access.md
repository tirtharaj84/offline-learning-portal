# Set up and access your portal

Offline Learning Portal v1.0.0 | Copyright 2026 Tirtharaj Dhungana | MIT

## A school library on your local network

Offline Learning Portal lets learners open resources in a browser using a school Windows server. Start with these three guides, then add resources the school is permitted to host. Internet access is not needed to browse files that are fully local; it may be needed to obtain software or new resources.

### Before you begin

- Use a Windows machine with Windows PowerShell 5.1 and permission to administer services and firewall rules. Keep a backup of school resources.
- Extract the complete ZIP before launching anything. The supplied NGINX and NSSM binaries and their notices are already in vendor/.
- Choose a dedicated destination, normally C:\LearningPortal. The extraction folder may contain spaces; the installation destination must not.
- Use an available port. The default is TCP 80; if occupied, setup offers an alternative such as 8080. Use the chosen port in every URL.

### Find the right file

| Item | What it does |
| --- | --- |
| Install.bat | Launches Windows installation |
| portal-settings.json | Sets destination, name, port and firewall scope |
| web/resources/ | Holds documents, media and local activities |
| Rebuild_Catalog.bat | Updates resource cards after changes |
| Uninstall.bat | Offers preserve-files or full-removal options |

The main service is OfflineLearningPortal. NSSM keeps NGINX running as a Windows service. Optional Kiwix is introduced in Guide 03 and is separate from this baseline.


## Install once; choose the name deliberately

### 1. Review settings before installation

```
"install_directory": "C:\\LearningPortal",
"hostname": "Portal",
"http_port": 80
```

This is an excerpt from portal-settings.json, not a complete JSON file. Keep JSON commas and boolean values valid. Destination paths use doubled backslashes in JSON. Choose a unique computer name up to 15 characters, beginning with a letter, with letters, digits or hyphens.

### 2. Start the installer

- Right-click Install.bat and select Run as administrator. Review the destination, service name, HTTP port and firewall scope.
- Type YES to continue. Setup creates NGINX runtime directories, validates configuration, installs/configures NSSM, adds rules, starts the service and checks the local catalogue.
- At the rename prompt, type RENAME only to change the Windows computer name. Pressing Enter keeps the current name. A configured hostname does not create a DNS record.
- If you accept renaming, restart Windows to complete the name change. Coordinate changes on managed school/domain computers with their administrator.

### 3. Open the home page

```
http://localhost/
http://SERVER-IP/
http://ACTUAL-HOSTNAME/
```

Replace SERVER-IP and ACTUAL-HOSTNAME with your actual values. If you chose port 8080, use http://SERVER-IP:8080/. On a learner phone, localhost means the phone itself: use the server IP or resolvable server name.

### Read success accurately

A successful installer health check confirms a running service and local catalogue response. It does not by itself prove client access or name resolution. Editing portal-settings.json later does not apply changes to an installed server.


## Check the service, browser and removal

### 1. Read the current state in PowerShell

```
Get-Service OfflineLearningPortal
hostname
Get-NetIPAddress -AddressFamily IPv4 |
  Where-Object {$_.IPAddress -notlike '127.*'} |
  Select-Object InterfaceAlias,IPAddress
Get-NetTCPConnection -State Listen |
  Where-Object LocalPort -eq 80
```

Expected: service status Running and a listener on your configured port. Choose the IP of the school Wi-Fi/Ethernet adapter, not a VPN or virtual adapter. With example IP 192.168.1.25, open http://192.168.1.25/ from a learner phone. Replace it with your actual IP; add :8080 if that is your chosen port.

### 2. Test restart and a resource

Restart Windows. Open the portal without manually starting a service. Open a guide, use search, then add the worked example in Guide 02. Disconnect internet while keeping the school LAN connected and check again. IP works but name fails: check the actual hostname and school name resolution. Localhost works but a phone fails: check network profile, firewall scope and Wi-Fi client isolation.

### 3. Back up and uninstall

Back up web, portal-settings.json, installation.json and runtime/nginx/conf/portal.conf. Run the installed Uninstall.bat as administrator. Choose 1 to preserve files or 2 to delete the installation, then answer REMOVE and, for deletion, DELETE. The optional Kiwix service has separate removal steps in Guide 03.

If an old page remains visible, try an explicit http:// URL in a private window and check the listener output above. An old cached page is not evidence that a server is running. Retain logs and installation.json when troubleshooting a failed installation.

### Evidence and references

The owner supplied Windows installation, local health, LAN IP access and full-removal evidence. New example code has preparation checks; this exact archive and optional Kiwix need local review. See docs/VALIDATION.md. NGINX Windows guidance: https://nginx.org/en/docs/windows.html ; NSSM: https://nssm.cc/usage .


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

The Windows path C:\LearningPortal\web\resources\Activities\lesson-starter\index.html becomes http://localhost/resources/Activities/lesson-starter/index.html on the server. web is the server document root and is omitted from the URL. On a learner device replace localhost with the server IP or working hostname. A browser URL uses forward slashes; a Windows path normally uses backslashes.

### Before editing

- Make a dated backup of web on another drive or device. Do not put your only backup inside a folder you may uninstall.
- Enable filename extensions in Explorer: View > Show > File name extensions on Windows 11; View > File name extensions on Windows 10. Menu wording can vary.
- For a text file, right-click > Open with > Notepad. On newer Windows, Show more options may be needed. Save as UTF-8 and All Files when creating a file.
- Refresh the browser after saving. A content edit does not need service reinstallation. Changes to generated catalog.json will be overwritten by the next rebuild.

### Which guide next?

Guide 02 builds a fresh local lesson using HTML, CSS and JavaScript, then adds media and optional Python. Guide 03 adds an independent Kiwix server and explains downloading its software and ZIM files. Neither requires the author's earlier portal code. Work through one page at a time and check the stated result before continuing.


Creator contact: Tirtharaj Dhungana <tirtharajdhungana84@gmail.com>.
