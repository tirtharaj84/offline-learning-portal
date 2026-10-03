# Implementation and testing history

Project: Offline Learning Portal. Consolidated candidate: 1.0.0-rc.1. Record date: 3 October 2026 (Nepal). Source of Windows observations: the project owner's conversation reports and copied console outputs, not independent access to the owner's computer.

## Design decisions
The owner's earlier working portal used NGINX and Kiwix, NSSM-managed Windows services, hostname/IP access, firewall rules and a substantial collection of local educational resources. The new baseline retains local hosting and service management but replaces collection-specific dependencies with a generic catalogue and three original PDF demonstrations. Schools may add permitted PDFs, media or complete HTML resources. Kiwix and 3D viewers are optional integrations, not installed by this baseline. NSSM is a service wrapper, not a scraper. The project does not scrape websites.

Default new installation: C:\LearningPortal; service OfflineLearningPortal; configured hostname Portal; TCP 80; inbound access limited to Private/Domain profiles and LocalSubnet. Python is needed to rebuild the catalogue, not to run the bundled initial portal. A separately confirmed computer rename is optional. Pressing Enter retains the existing name.

## Observed issues, fixes and outcomes
| Stage | Observation from the owner | Action and outcome |
|---|---|---|
| Old portal cleanup | Owner successfully ran revised legacy rollback | Old C:\nginx deployment removed. Legacy cleanup was kept separately for office machines and removed from the new package. |
| Browser showed old page | localhost still appeared to display old content after old cleanup | Port-80 query reported no matching listening connection. Cached/browser-managed content was suspected; no precise browser cause was established. |
| Binary placement | Owner supplied nginx.exe and nssm.exe | Executables placed in vendor paths; NGINX configuration support files came from the owner's supporting ZIP. Binaries were not executed in the preparation environment. |
| v0.1.1 path validation | Valid C:\LearningPortal rejected before installation changes | A wrongly escaped regular expression was corrected in v0.1.2. No cleanup required for that preflight rejection. |
| v0.1.2 configuration test | Syntax passed; CreateDirectory temp/client_body_temp failed because parent was missing | v0.1.3 explicitly creates logs, temp and five default temporary subfolders before nginx -t. Partial installation was uninstalled/preserved, renamed, later deleted by owner. |
| v0.1.3 installation | Copied console output reported successful nginx -t, service registration/settings and local catalogue HTTP health check | Installation success supported by console output. Owner pressed Enter at rename prompt, so no new computer rename was performed in this test. Printed Portal URL is not evidence of name resolution. |
| LAN access | Owner reported access from mobile and other devices at http://10.122.200.253/ | IP-based access on the test LAN supported. That address is an observation, not a portable default or permanent address. |
| Initial uninstall concern | Folder remained and content appeared accessible after BAT use | Default BAT kept files; owner was directed to installed PowerShell script with -DeleteFiles. Exact cause of the initial still-accessible page was not established. |
| Full uninstall | Console output confirmed service removed and installed folder deleted after REMOVE and DELETE | PowerShell full-removal path successfully exercised. The output's deletion prompt omitted the folder text; owner still confirmed deletion. |
| Uninstall menu | Owner requested full deletion through BAT | BAT now offers keep files / delete files / cancel and invokes the same PowerShell script. Included in owner's final ZIP. No separate copied console record demonstrates the menu branch itself. |
| Browser discrepancy after removal | Chrome no longer loaded portal; Brave showed older content | Localhost-only storage/service-worker cleanup was suggested. The owner subsequently reported everything tested and working; no explicit Brave remediation result was provided. |
| Final confirmation | Owner stated everything was tested and working properly and supplied the final ZIP | Record as overall owner acceptance; do not invent separate measurements or logs for checks not individually reported. |

## Interpretation for publication
The evidence supports successful installation with a local catalogue health check, IP-based LAN access from more than one client, and full service/folder uninstall in the reported environment. It is a functional demonstration. It does not establish pedagogical effectiveness, curriculum alignment, benchmark performance, concurrent-user capacity, reliability across Windows versions or deployments across multiple schools.

The conversation's overall acceptance does not provide detailed per-check records for reboot persistence, deliberate application failure/recovery, hostname resolution, adding/rebuilding a resource, individual PDF/search behaviour or offline HTML dependencies. Mark these as owner acceptance without detailed evidence rather than as independently verified tests. Do not carry over original portal test results as new starter measurements.

Recorded environment: Windows PowerShell console and NGINX/NSSM Windows executables. Exact Windows edition/build, device models, client browser versions, network topology, number of concurrent clients and test durations were not supplied. Fill these from deployment notes if needed; do not infer them from unrelated account history.
