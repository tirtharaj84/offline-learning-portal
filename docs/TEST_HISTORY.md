# Technical test history — v1.0.0

Record date: 3 October 2026, Nepal.

Windows observations were supplied by the project owner through reports and copied console output. Package preparation checks were performed separately.

Historical version labels below identify the revisions discussed during troubleshooting. They are not claims that each revision has a separate public release.

## Baseline configuration

| Setting | Baseline value |
|---|---|
| Installation destination | `C:\LearningPortal` |
| Windows service | `OfflineLearningPortal` |
| Configured hostname | `Portal` |
| HTTP port | TCP 80 |
| Inbound firewall profiles | Private and Domain |
| Inbound remote-address scope | LocalSubnet |
| Web server | NGINX |
| Windows service wrapper | NSSM |
| Catalogue rebuilding | Python |
| Initial browsing | Python not required |
| Computer rename | Optional; separately confirmed |

Pressing Enter at the rename prompt retains the existing computer name. A configured hostname does not establish DNS or other network name resolution.

The baseline uses one web service. Kiwix and specialised resource viewers require separate configuration.

## Issues, changes and recorded outcomes

| Stage | Recorded issue or action | Change or outcome |
|---|---|---|
| Legacy portal cleanup | Owner ran the revised legacy rollback procedure | Owner reported removal of the old `C:\nginx` deployment |
| Old page after cleanup | `localhost` appeared to display older content | A port-80 query reported no matching listening connection; the browser-specific cause was not established |
| Executable placement | Owner supplied `nginx.exe` and `nssm.exe` | Executables were placed in the package vendor paths |
| NGINX support files | Owner supplied a supporting ZIP | Required NGINX configuration support files were included |
| v0.1.1 path validation | Valid `C:\LearningPortal` destination was rejected before installation changes | The incorrectly escaped regular expression was corrected in v0.1.2 |
| v0.1.2 NGINX configuration check | Syntax passed, but creation of `temp/client_body_temp` failed because its parent directory was missing | v0.1.3 explicitly created `logs`, `temp` and the required temporary subdirectories before running `nginx -t` |
| Partial installation cleanup | Owner removed or preserved the partial installation during troubleshooting | Owner subsequently renamed and deleted the retained directory |
| v0.1.3 installation | Console output showed successful NGINX configuration checking, service registration/settings and a local catalogue HTTP check | Installation passed in the reported environment |
| Rename prompt | Owner pressed Enter | Computer rename was skipped; the printed hostname URL did not verify name resolution |
| LAN access | Owner reported successful access from mobile and other devices using the server IP address | IP-based LAN access passed |
| Initial uninstall behaviour | Installed files remained after BAT use | The BAT then preserved files by default; the owner was directed to the PowerShell removal option |
| Full uninstall | Console output showed removal of the service and installed directory after confirmation | Full removal passed |
| Deletion prompt display | Directory text was omitted from the displayed deletion prompt | Owner confirmed deletion; output showed completion |
| Uninstall menu revision | Owner requested full deletion through the BAT interface | The BAT was revised to offer keep files, delete files and cancel |
| Uninstall menu branch execution | Revised menu was included in the submitted package | Separate copied output for each menu branch was not supplied |
| Browser behaviour after removal | Chrome no longer loaded the portal; Brave displayed older content | Localhost storage/service-worker cleanup was suggested; exact Brave remediation was not recorded |
| Occupied-port handling | Alternative-port handling was implemented | A separate occupied-port execution record was not supplied |
| Final deployment acceptance | Owner reported that testing was completed and everything was working properly | Recorded as overall owner acceptance |
| Published v1.0.0 archive review | Owner confirmed that the published archive passed review testing | Recorded as passed on owner confirmation; detailed per-check review logs were not supplied |

## Preparation checks

The package preparation record includes:

- Six passing catalogue tests:
  - encoding and defaults;
  - explicit HTML registration and ignored extensions;
  - invalid metadata handling;
  - preservation of the existing catalogue after an error;
  - external symlink rejection;
  - deterministic output.
- Passing JavaScript syntax checks.
- Successful temporary HTTP checks for the home page, catalogue and three guides.
- PDF text extraction for guides containing 4, 10 and 10 pages.
- Visual inspection of all 24 rendered PDF pages.
- ZIP integrity checking.
- Python media-path fixture checks, including a filename with spaces.
- Registration of the lesson HTML sidecar and ordinary media entries in a temporary web-directory copy.
- DOM simulation checks for answer visibility, shelf links and failed-fetch handling.

PowerShell and the supplied Windows executables were not run in the preparation environment. A Playwright smoke test could not run because a browser executable was unavailable.

## Evidence boundaries

Supplied console output supports:

- NGINX configuration checking;
- service installation and startup;
- local catalogue availability;
- full service and directory removal.

Owner reports support:

- client access over the test LAN using the server IP address;
- Chrome being unable to access the portal after removal;
- overall deployment acceptance;
- successful review testing of the published v1.0.0 archive.

Separate individual records were not supplied for:

- reboot persistence;
- deliberate application failure and recovery;
- hostname resolution;
- every search/PDF interaction;
- resource addition and rebuilding on Windows;
- each uninstall menu branch;
- an occupied-port installation;
- browsing with internet connectivity disconnected.

## Optional integration status

Kiwix/ZIM hosting, optional reverse proxy routing and specialised viewers were not executed as part of the recorded baseline preparation checks.

Their documentation does not constitute an execution result.

## Environment details retained

The supplied records identify Windows, Windows PowerShell, NGINX/NSSM Windows executables and access from mobile and other LAN devices.

They do not specify the exact Windows edition/build, server hardware, client device models, browser versions, complete network topology, simultaneous client count or test durations.

No missing environment details or measurements have been inferred.
