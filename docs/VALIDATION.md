# Technical validation — v1.0.0

## Scope

This record covers the installation scripts, NGINX/NSSM service configuration, resource catalogue, bundled guides, lesson example, LAN access and uninstallation.

Checks performed during package preparation are listed separately from checks performed by the project owner on Windows.

## Package preparation checks

| Check | Recorded result |
|---|---|
| Catalogue encoding and default metadata | Passed |
| Explicit HTML registration and ignored extensions | Passed |
| Invalid metadata handling | Passed |
| Preservation of the existing catalogue after an error | Passed |
| External symlink rejection | Passed |
| Deterministic catalogue output | Passed |
| JavaScript syntax | Passed |
| HTTP access to the home page, catalogue and three PDFs using a temporary Python server | Passed |
| PDF text extraction | Passed; guides contained 4, 10 and 10 pages |
| Visual inspection of generated guides | All 24 rendered pages inspected |
| ZIP integrity during preparation | Passed |

PowerShell scripts and the bundled Windows executables were not executed in the preparation environment. A Playwright smoke-test attempt could not run because a browser executable was unavailable.

## Windows deployment results

| Check | Recorded result | Evidence |
|---|---|---|
| NGINX configuration test | Passed | Supplied console output |
| Service installation and startup | Passed | Supplied console output |
| Local catalogue availability | Passed | Supplied console output |
| Access from mobile and other devices using the server IP address | Passed | Owner report |
| Full removal of the Windows service and installed directory | Passed | Supplied console output |
| Chrome access after removal | Portal unavailable as expected | Owner report |
| Overall deployment testing | Passed | Owner confirmation |
| Review testing of the published v1.0.0 archive | Passed | Owner confirmation |

The owner confirmed that testing was completed and the portal was functioning correctly. Detailed individual logs for the published-archive review were not supplied with the recorded materials.

## Checks with limited individual records

| Check | Recorded status |
|---|---|
| Windows restart persistence | Covered by overall owner acceptance; separate result not recorded |
| Deliberate application failure and automatic recovery | Separate result not recorded |
| Hostname resolution | Separate result not recorded |
| Search and individual PDF behaviour | Covered by overall owner acceptance; separate results not recorded |
| Resource addition and catalogue rebuilding on Windows | Covered by overall owner acceptance; separate result not recorded |
| Uninstall BAT menu branches | Implemented; separate branch-execution output not recorded |
| Occupied-port handling and alternative-port installation | Implemented; separate conflict-test output not recorded |
| Brave displaying older content after removal | Reported; exact cause and resolution not recorded |
| Browsing with the internet connection disconnected | Separate result not recorded |
| Concurrent-client capacity and response times | Measurements not recorded |

These statuses describe the available records. They do not represent separately documented failures.

## Lesson example checks

The following checks were performed during preparation:

- The Python media-list script was exercised with PDF and audio path fixtures, including a filename containing spaces.
- Generated resource URLs resolved correctly in the preparation environment.
- A temporary web-directory copy registered the lesson HTML metadata sidecar and ordinary media entries.
- JavaScript syntax checks passed.
- A DOM simulation checked answer visibility, shelf links and the failed-fetch message.

These checks were not real-browser or Windows deployment tests.

## Optional components

Kiwix, ZIM collections, reverse proxy routing and specialised viewers are optional integrations.

The Kiwix commands and routing guidance were checked against official documentation. A Kiwix service, ZIM archive, optional reverse proxy and optional cleanup procedure were not executed on Windows during package preparation.

Their operation is not included in the baseline Windows results above.

## Recorded environment

- Operating system family: Windows.
- Shell shown in supplied deployment output: Windows PowerShell.
- Web server: supplied NGINX Windows executable.
- Service wrapper: supplied NSSM Windows executable.
- Client access: mobile and other devices on the test LAN.
- Confirmed access method: server IP address.

The exact Windows edition/build, hardware models, browser versions, network topology, simultaneous client count and test durations were not supplied in the recorded materials.

## Procedure for reproducing the checks

1. Extract the package and review `portal-settings.json`.
2. Use a dedicated destination that does not contain an existing portal installation.
3. Run `Install.bat` as administrator.
4. Review the destination, service name, port and firewall scope before confirming installation.
5. Retain the NGINX configuration-test output, service output and local HTTP health-check result.
6. Open the portal on the server and from another device using the server IP address.
7. Check catalogue search, PDF access and any locally registered HTML resources.
8. Add an authorised test resource and run `Rebuild_Catalog.bat`.
9. Restart Windows and repeat the local and client access checks.
10. Back up resources before testing removal.
11. Run the installed `Uninstall.bat` and select the intended preservation or deletion option.
12. For full deletion, complete the required `REMOVE` and `DELETE` confirmations.
13. Record the service and directory state after removal.

For any additional validation record, retain the package checksum, test date, Windows build, server/client details, selected settings and actual results.
