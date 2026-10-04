# Technical validation - v1.1.0

## Scope

Interactive installation/removal, ownership checks, NGINX/NSSM service setup, port selection, confirmed temporary IIS interruption, IP-address access, resource catalogue and package documentation.

## Windows acceptance

The project owner reported: "everything passed on my PC also". Confirmation was received on 4 October 2026 for the interactive installation and removal testing package. This is recorded as passed owner-reported Windows acceptance.

Detailed per-check output, Windows edition/build, hardware, browser versions, network layout and timing were not supplied with this confirmation. This record does not invent those details or claim independent repetition of each Windows check. The reproducible procedures are retained in INTERACTIVE_SETUP_TEST.md.

Finalisation changes remove pre-release labels and update publication/version metadata and guide footers; no new installation/removal behaviour was added after the reported acceptance.

## Preparation checks

| Check | Recorded result | Evidence boundary |
|---|---|---|
| PowerShell parsing | Passed; seven files | PowerShell 7.4.6 on Linux; not independent Windows PowerShell 5.1 execution |
| Port/IIS helper checks | Passed; ten assertions | Windows commands mocked |
| Catalogue tests | Passed; six tests | Python preparation environment |
| Removal-engine tests | Passed; six tests | Disposable POSIX folders and mocked Windows service/firewall commands |
| Package JSON | Parsed successfully | Settings, guides and metadata |
| Guide layout | 4, 10 and 10 pages; rendered pages inspected | PDF preparation environment |
| ZIP integrity and checksums | Verified during final packaging | SHA256SUMS.txt covers distributed files except itself |

Removal-engine tests cover keeping files, deleting the owned directory, cancellation, mismatched ownership, a different service application and an unrelated firewall-rule name. They exercise the runner, not Windows Forms callbacks. The administrative requirement is removed only from disposable test copies; the shipped runner retains it.

Port helper tests cover free-port selection, inventory failure, unrelated process ownership, inactive IIS site/service, conditional W3SVC stopping and restoration when port 80 remains occupied.

## Limits and optional components

Windows acceptance is supported by the owner report. Portable checks do not independently verify native GUI rendering, UAC, real IIS/shared HTTP.sys behaviour, actual firewall/service changes or Windows file locks. Optional Kiwix/ZIM and reverse-proxy deployment are outside the recorded preparation execution. No capacity, response-time or learning-outcome measurements are claimed.

The prior v1.0.0 archive has its own historical validation record. Version 1.1.0 introduces new interactive behaviour and should be cited by its own release/version record.
