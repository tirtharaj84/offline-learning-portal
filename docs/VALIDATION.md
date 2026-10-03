# Validation record — 1.0.0

## Preparation-environment checks
Six catalogue tests passed: encoding/defaults, explicit HTML registration and ignored extensions, invalid metadata, preservation of existing catalogue after error, external symlink rejection and deterministic output. JavaScript syntax check passed. HTTP checks using a temporary Python server succeeded for home, catalogue and all three PDFs. The three replacement guides have 4, 10 and 10 extractable text pages; all 24 rendered pages were inspected. ZIP integrity was checked.

PowerShell/NGINX executables were not run in the preparation environment. A Playwright smoke-test attempt lacked a browser executable. These limitations do not negate the owner's later Windows observations; they distinguish who performed each check.

## Owner's Windows observations
| Check | Evidence status |
|---|---|
| NGINX configuration test | Passed; console output supplied |
| Service installation/start and local catalogue | Passed; console output supplied |
| Mobile/other-device LAN access by IP | Passed; explicit owner report |
| Full uninstall: service and folder | Passed; console output supplied |
| Chrome access after uninstall | Unavailable as expected; explicit owner report |
| Restart persistence, hostname, search/PDF detail, add/rebuild, recovery | Owner gave overall acceptance; individual results/logs not supplied |
| Brave old-page discrepancy | Reported; precise cause and remediation outcome not documented |
| Uninstall BAT menu | Present in submitted final ZIP; separate branch execution log not supplied |
| Alternative-port/IIS conflict branch | Implemented; no occupied-port test record supplied |

The owner declared all testing completed and functioning correctly. docs/TEST_HISTORY.md retains the more specific evidence and limits. Do not label the package as independently validated in every supported configuration.

## Reproduce
Use a dedicated fresh destination. Run Install.bat as administrator, confirm destination/name/port/scope, accept YES, and record output. Test localhost and client IP access. Record actual hostname (a skipped rename retains it). Test PDFs/search, resource additions and a Windows restart. Back up, then use the installed Uninstall.bat menu; full deletion requires REMOVE and DELETE. Preserve console evidence and exact versions with test notes. A released package should be tested as packaged before publishing v1.0.0.

## Optional Kiwix limitation
The Kiwix commands and NGINX routing guidance were checked against official documentation. No Kiwix service, ZIM archive, reverse proxy or optional cleanup was executed on Windows during this revision. These are optional examples requiring local validation.

## Expanded novice revision
All 24 PDF pages were rendered and inspected. The fresh Python script was exercised with PDF/audio path fixtures including a filename with spaces; generated URLs resolved correctly. A temporary main-web copy successfully registered the lesson HTML sidecar and ordinary media entries. JavaScript syntax passed; a DOM simulation checked show/hide answer, shelf links and the failed-fetch message. These checks are not a real-browser or Windows deployment test. Example code is newly authored, without reuse of prior portal code.
