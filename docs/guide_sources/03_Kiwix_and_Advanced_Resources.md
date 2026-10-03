# Extend with Kiwix and advanced resources

Offline Learning Portal v1.0.0 | Copyright 2026 Tirtharaj Dhungana | MIT

## 1. Understand the optional Kiwix extension

The portal serves ordinary files such as PDF, audio, video and HTML. A ZIM file is a packaged offline collection, often containing many pages and images. It needs a ZIM reader/server; placing a .zim under resources does not make its pages available in the static catalogue.

### What you will build

The main portal remains in C:\LearningPortal and normally uses port 80. Optional Kiwix lives in C:\KiwixPortal, runs as OfflineLearningKiwix and uses example port 8081. Learners open http://SERVER-IP:8081/ for its library. NSSM keeps this separate application running as a Windows service; it is a service wrapper, not a content scraper.

### Work through the pages in order

- 2: download the Windows server software, keeping its full extracted contents.
- 3: download one suitable small ZIM archive and record its source.
- 4-5: create folders and test Kiwix manually on the server.
- 6: add a narrow firewall rule and test another device.
- 7: register automatic service operation using NSSM.
- 8: add a simple portal homepage link and test a restart.
- 9-10: expand, back up, troubleshoot and remove Kiwix independently.

### Prepare before starting

- Use the Windows school server, an administrator account, internet for downloads and enough free disk space for archive plus backups.
- The main portal should already work. Back up its web folder before adding a homepage link.
- Use one archive first. Huge Wikipedia collections are unnecessary for learning this setup.
- These commands assume C:\KiwixPortal and port 8081; use them consistently. If 8081 is occupied, select a free port and update every command, rule and URL.

### Status of this example

Kiwix is not bundled in the portal ZIP and is not installed by Install.bat. This fresh walkthrough is checked against official documentation; its Windows service, firewall and archive operations still require local validation. The main portal's tested baseline is recorded separately in docs/VALIDATION.md.


## 2. Download the Windows Kiwix server software

### Step 1 - choose the correct product

On the server while online, open https://get.kiwix.org/en/solutions/applications/download-options/ . Scroll to Kiwix Server, not the Kiwix reader section. Select its Windows download. On 3 October 2026 the Server link is labelled Windows x86; do not choose a Linux tarball, macOS package or Docker image for this Windows executable exercise.

The ordinary Kiwix reader is useful for reading on one computer, but this guide needs kiwix-serve.exe for sharing over the network. Download buttons and versions may change. The official Server page also links to current download options: https://get.kiwix.org/en/solutions/applications/kiwix-server/ .

### Step 2 - save and extract the archive

- Save the server ZIP into Downloads. Wait until the browser marks the download complete; a partial download is not usable.
- Press Windows+E, open Downloads, right-click the ZIP and choose Extract All. Extract into a temporary Downloads subfolder. Do not run from inside the compressed-folder view.
- Open the extracted folders and locate kiwix-serve.exe. Use Explorer search if needed. Check that filename extensions are visible.
- Keep all accompanying DLLs, data folders and licence/readme files. Do not copy only the EXE and discard its dependencies.
- On page 4 you will copy the entire contents of the folder containing the executable into C:\KiwixPortal\server.

### Check the download before continuing

You should have a real file named kiwix-serve.exe and its accompanying files. If you only have a reader application or a Linux binary, return to the Server download section. If Windows reports a damaged archive, redownload from the official link and verify any checksum published by that release. Do not disable protections to run an unexplained file.

### Keep a download record

Create a Notepad note in your backup location with download URL, date and release filename. Keep the original ZIP. The server version may differ from the archive dates: one is software, the others are content releases. The page-5 help/version checks determine whether your chosen build supports these options.


## 3. Download a ZIM collection for your first test

### Step 1 - browse the official library

Open https://library.kiwix.org/ in a normal browser while online. If an access confirmation appears, confirm it. Use the library's language and content filters/search to select a small, suitable collection. The interface may change; open the chosen collection's details and download options.

### Step 2 - choose a manageable edition

Check the language, title, date, size and whether the collection includes images/videos. A smaller or text-only collection is easier to download first. Avoid assuming that a title guarantees curriculum suitability. Preview the collection where available, and note the original content licence.

### Step 3 - download an actual .zim

- Use the direct download option for the collection, saving to Downloads. A torrent needs a torrent client; choose the direct file for this beginner exercise.
- Wait for completion and compare the file size with the download details. A .part or .crdownload file is incomplete.
- Check Explorer shows a .zim extension. An HTML library page saved from the browser is not a ZIM.
- Keep the original downloaded filename in your source records and a backup copy.
- For the simple commands in this workbook, make a COPY named starter.zim. Renaming the copied .zim is only a filename change; it does not convert any other file type into ZIM.

### Step 4 - record the content separately

With Notepad make a note of collection title, original filename, language, source URL, date, size and content licence. You will save it as C:\KiwixPortal\archive-sources.txt on page 4. The portal's MIT licence does not relicense the downloaded collection. Do not make assumptions based only on free download availability.

### If the download is very large or unreliable

Choose a smaller archive first. A transfer can be made on another online computer and copied to the server by USB; keep its filename and integrity intact. Verify a published checksum if available. Do not split the file by hand. Test one archive successfully before expanding to several.

You now need two different things: the extracted kiwix-serve server software from page 2, and starter.zim content from this page. Neither substitutes for the other.


## 4. Create the directories and place every file

### Step 1 - make the directory tree in Explorer

Press Windows+E, open This PC > Local Disk (C:), right-click an empty area > New > Folder and name it KiwixPortal. Approve the Windows permission prompt if appropriate. Open it and create three folders: server, content and logs. If KiwixPortal already contains a working deployment, back it up and do not overwrite it for this exercise.

```
C:\KiwixPortal\server\kiwix-serve.exe
C:\KiwixPortal\server\...accompanying server files...
C:\KiwixPortal\content\starter.zim
C:\KiwixPortal\logs\
C:\KiwixPortal\nssm.exe
C:\KiwixPortal\archive-sources.txt
```

### Step 2 - copy software and content

- From the extracted download on page 2, copy all contents of the folder containing kiwix-serve.exe into server. Check the final path is server\kiwix-serve.exe, not server\another-folder\kiwix-serve.exe. Preserve accompanying subfolders.
- Copy your starter.zim into content. Keep the original download backed up elsewhere.
- Leave logs empty; the service will write stdout.log and stderr.log there.
- Save your source/licence note as archive-sources.txt at the KiwixPortal top level using Notepad.

### Step 3 - give this deployment its own NSSM copy

In your extracted portal ZIP, locate vendor/nssm.exe and its notices. If the layout differs, search that ZIP folder for nssm.exe. Copy the executable to C:\KiwixPortal\nssm.exe and keep its notices in a separate notices subfolder. Do not use a service-wrapper path inside C:\LearningPortal: uninstalling the main portal would then remove the optional service's dependency.

### Confirm in PowerShell

```
Test-Path C:\KiwixPortal\server\kiwix-serve.exe
Test-Path C:\KiwixPortal\content\starter.zim
Test-Path C:\KiwixPortal\nssm.exe
Test-Path C:\KiwixPortal\logs
```

Open Start > PowerShell for these read-only checks. Each should print True. A False means the file/folder is missing or nested incorrectly. Fix the location before page 5. Do not save PowerShell commands into nginx.conf or HTML: commands are run in the terminal.


## 5. Run one archive manually before creating a service

### Step 1 - check version and supported options

```
& C:\KiwixPortal\server\kiwix-serve.exe --version
& C:\KiwixPortal\server\kiwix-serve.exe --help
Get-NetTCPConnection -State Listen |
  Where-Object LocalPort -eq 8081
```

The & sign runs the named executable in PowerShell. The first commands should print version/help. The listener command should show no row for a free 8081. If it shows another process, choose a free port and revise the guide values consistently. A DLL error means server dependencies were not copied or the download is incompatible; return to page 2.

### Step 2 - start the foreground server

```
$app = 'C:\KiwixPortal\server\kiwix-serve.exe'
$zim = 'C:\KiwixPortal\content\starter.zim'
& $app --port=8081 --address=0.0.0.0 $zim
```

Copy all three lines into PowerShell. $app and $zim are short variable names holding paths. 0.0.0.0 means listen on available IPv4 interfaces; it is not a URL to type in a browser. Leave this terminal open while testing. This is a foreground process, so the prompt may not return until you stop it.

### Step 3 - test in the server browser

- Open a second window, launch a browser and type http://localhost:8081/ .
- Expected: the Kiwix library with your selected collection. Open it and navigate to an actual page.
- Check an image if included; try search if this archive supports it. Search is not guaranteed for every ZIM.
- An invalid archive or missing file message means verify starter.zim and its completed download; changing the portal catalogue will not fix it.

### Step 4 - stop correctly

Click the PowerShell window running Kiwix and press Ctrl+C. After it exits, the prompt should return. This is how to stop the manual process before starting a managed service on the same port. Keep it running for the page-6 LAN test, then stop it before page 7.

Do not create a Windows service until this local test works. If it fails, fix the software, archive or port rather than repeatedly installing services.


## 6. Permit the chosen port and test a learner device

### Step 1 - use an administrator PowerShell window

Open Start, type PowerShell, right-click Windows PowerShell and choose Run as administrator. Approve the prompt. Read-only checks can run normally, but adding firewall rules and services requires administrator rights. Restart the manual Kiwix process from page 5 if it is stopped.

### Step 2 - inspect the network and existing rule

```
Get-NetConnectionProfile
Get-NetFirewallRule -Name OfflineLearningKiwix-HTTP `
  -ErrorAction SilentlyContinue
```

The school connection should be an authorised Private or Domain network. The rule check should find nothing for a new deployment. If the rule already exists, inspect the existing setup; do not create duplicate rules. The backtick at the end of a line continues a PowerShell command; do not add spaces after it.

### Step 3 - create this specific inbound rule

```
New-NetFirewallRule -Name OfflineLearningKiwix-HTTP `
  -DisplayName 'School Kiwix TCP 8081' `
  -Direction Inbound -Action Allow -Protocol TCP `
  -LocalPort 8081 -Profile Private,Domain `
  -RemoteAddress LocalSubnet `
  -Program C:\KiwixPortal\server\kiwix-serve.exe
```

This allows the chosen executable/port from LocalSubnet on Private and Domain profiles. It does not intentionally open a Public profile or all internet addresses. No router port forwarding is needed for this school-LAN example. If using a different port/path, update them before running.

### Step 4 - find the school server IP

```
Get-NetIPAddress -AddressFamily IPv4 |
  Select-Object InterfaceAlias,IPAddress
```

Choose the school Ethernet/Wi-Fi address, not loopback, VPN or a virtual adapter. With example address 192.168.1.25, open http://192.168.1.25:8081/ from a phone on the same school network. Replace the example IP. localhost on the phone points to the phone itself.

### If only the server can open it

Confirm the manual process is running, correct adapter/IP, same LAN, selected port and Private/Domain profile. Wi-Fi client isolation can block device-to-device access. Check the network policy with the administrator instead of disabling the firewall. When LAN access succeeds, stop the manual process with Ctrl+C before page 7.


## 7. Register Kiwix as an automatic NSSM service

### Step 1 - check for an existing service

Use administrator PowerShell. Run the next check. If it returns a service, inspect the existing deployment and stop this new-install exercise; do not overwrite another school service.

```
Get-Service OfflineLearningKiwix -ErrorAction SilentlyContinue
```

### Step 2 - set variables and register the executable

```
$nssm = 'C:\KiwixPortal\nssm.exe'
$app = 'C:\KiwixPortal\server\kiwix-serve.exe'
$service = 'OfflineLearningKiwix'
$params = '--port=8081 --address=0.0.0.0 ' +
  'C:\KiwixPortal\content\starter.zim'
& $nssm install $service $app
& $nssm set $service AppDirectory C:\KiwixPortal\server
& $nssm set $service AppParameters $params
& $nssm set $service Start SERVICE_AUTO_START
```

Run one command at a time and read its output. After an NSSM command, $LASTEXITCODE should be 0; a nonzero value or error means stop and fix that command before proceeding. Variables exist only in this terminal; if you reopen it, rerun their assignments. The server starts in its own software directory.

### Step 3 - configure restart and logs

```
& $nssm set $service AppExit Default Restart
& $nssm set $service AppStdout C:\KiwixPortal\logs\stdout.log
& $nssm set $service AppStderr C:\KiwixPortal\logs\stderr.log
Start-Service OfflineLearningKiwix
Get-Service OfflineLearningKiwix
```

Expected: Running. AppExit asks NSSM to restart the application after exit; Start makes the Windows service automatic. stdout/stderr capture application output. Keep the app in foreground mode: do not add a Kiwix daemon/detach option under NSSM.

### Step 4 - check actual content, not only status

Open http://localhost:8081/ and the school-IP URL from a learner device. Check a page inside starter.zim. A running wrapper alone does not prove the app or archive works. If startup fails, read C:\KiwixPortal\logs\stderr.log in Notepad or use the page-9 commands. Service-account/permissions choices should follow school policy; these manual defaults do not constitute a hardened deployment.


## 8. Link Kiwix from the portal and test a restart

### Step 1 - choose a working address

On a learner device verify the IP URL http://SERVER-IP:8081/ or a resolvable actual hostname. The example below uses 192.168.1.25; replace it. A stable DHCP reservation helps avoid broken links when the server IP changes. Portal is only valid if that is the actual server name and clients can resolve it.

### Step 2 - back up and edit the homepage

- In Explorer open C:\LearningPortal\web. Copy index.html to a dated backup outside the live folder.
- Right-click index.html > Open with > Notepad. This is the main portal homepage, not your lesson's index.html.
- Press Ctrl+F and search for </main>. Insert the next HTML paragraph immediately BEFORE that closing tag. Keep the existing controls and scripts.
- Save with Ctrl+S. Do not replace the whole homepage with the snippet.

```
<p><a href="http://192.168.1.25:8081/">
  Open the school Kiwix library
</a></p>
```

### Step 3 - refresh and click from another device

Refresh the portal homepage using Ctrl+F5. The link should appear and open Kiwix. If it fails, type the same URL directly; this separates a bad link from a Kiwix/network issue. Do not put localhost in learner-facing links. No main catalogue rebuild is needed for this homepage edit.

### Why this link is outside catalog.json

Port 8081 is a different browser origin from port 80. The main portal catalogue deliberately accepts same-origin links, so inserting the Kiwix address there is unsupported. A homepage anchor is the simplest documented way to reach the optional service. It also keeps ZIM archives outside the static file catalogue.

### Step 4 - verify automatic startup

- Restart Windows at an appropriate time. Do not manually start either service first.
- Check Get-Service OfflineLearningPortal,OfflineLearningKiwix in PowerShell.
- Open the portal, click Kiwix, open an archive page and test from a learner phone.
- Disconnect internet while retaining the LAN connection and repeat. Record date, server software version, ZIM name and result.

Advanced same-port proxy configuration is in the separate appendix. It is optional and need not be applied to obtain a useful working Kiwix service.


## 9. Add a second archive, back up and troubleshoot

### Step 1 - download and place another genuine archive

Repeat page 3 for a second small collection. Keep its original filename in archive-sources.txt and a backup copy. For this exercise copy it into content as second.zim. Test its download integrity before replacing service arguments.

### Step 2 - update explicit service arguments

```
$nssm = 'C:\KiwixPortal\nssm.exe'
$params = '--port=8081 --address=0.0.0.0 ' +
  'C:\KiwixPortal\content\starter.zim ' +
  'C:\KiwixPortal\content\second.zim'
& $nssm set OfflineLearningKiwix AppParameters $params
Restart-Service OfflineLearningKiwix
```

Run in administrator PowerShell. The space after starter.zim separates the two file arguments. Both paths must exist. Refresh the library and verify both collections. Simply dropping a ZIM into content does not add it when the service arguments explicitly name only starter.zim.

### Read status and recent errors

```
Get-Service OfflineLearningKiwix
Get-Content C:\KiwixPortal\logs\stderr.log -Tail 30
Get-NetTCPConnection -State Listen |
  Where-Object LocalPort -eq 8081
& C:\KiwixPortal\nssm.exe get OfflineLearningKiwix AppParameters
```

- Service runs but browser fails: inspect listener and logs; confirm manual process is not conflicting with the service.
- Library lacks second archive: inspect AppParameters and the exact paths; restart after changing them.
- Archive page fails: test a completed genuine archive and check file access.
- IP URL works but hostname does not: repair name resolution or use the working IP; the Kiwix app cannot create DNS records.
- Storage grows: large ZIM files and logs need monitoring. Archive or rotate logs during maintenance rather than deleting active files blindly.

### Keep a recoverable copy

Back up the downloaded software ZIP, content, archive-sources.txt, service parameters and relevant portal homepage change. Retain licences/notices. Software and content can be restored separately. Replace a collection only after checking the new one; keep the prior working archive until the new version is accepted.


## 10. Remove optional Kiwix and keep a final record

### Step 1 - remove the learner link

Open C:\LearningPortal\web\index.html in Notepad and remove only the Kiwix paragraph you added on page 8. Save and refresh. The main portal is otherwise unchanged. Back up desired archives before any folder deletion.

### Step 2 - stop and remove the optional service

```
Stop-Service OfflineLearningKiwix
& C:\KiwixPortal\nssm.exe remove OfflineLearningKiwix confirm
Get-Service OfflineLearningKiwix -ErrorAction SilentlyContinue
```

Use administrator PowerShell. Read the removal output. The final check should return no service. If the stop command reports it is already stopped, inspect and continue only with the intended service removal; do not delete files while a running process still uses them.

### Step 3 - remove only its named firewall rule

```
Get-NetFirewallRule -Name OfflineLearningKiwix-HTTP `
  -ErrorAction SilentlyContinue | Remove-NetFirewallRule
Get-NetTCPConnection -State Listen |
  Where-Object LocalPort -eq 8081
```

An absent rule produces no result. A remaining listener means inspect the process before deleting anything; the port might be used by another application. Do not remove unrelated firewall rules or all NSSM services.

### Step 4 - delete the folder only if you intend full removal

After confirming the service is gone and no process uses the folder, open Explorer, select C:\KiwixPortal and delete it only after backing up wanted content. This is a deliberate manual deletion. The main portal uninstaller removes its own recorded service/rules and directory, not this separate Kiwix deployment. Its independent NSSM copy prevents an orphaned dependency.

### If you used an advanced proxy

Remove the appendix's /kiwix/ locations and homepage link, validate NGINX configuration and restart the main service. The direct-port exercise here does not modify NGINX configuration.

### Final record and official references

Record manual local test, LAN test, restart result, software version, archive source/licence, service name, port and any removal. Download options: https://get.kiwix.org/en/solutions/applications/download-options/ ; archive library: https://library.kiwix.org/ ; options: https://kiwix-tools.readthedocs.io/en/latest/kiwix-serve.html ; NSSM: https://nssm.cc/commands . Checked 3 October 2026. These new Windows steps require your own deployment test; no completed Kiwix test is claimed here.


Creator contact: Tirtharaj Dhungana <tirtharajdhungana84@gmail.com>.
