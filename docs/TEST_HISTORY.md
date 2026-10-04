# Technical test history - v1.1.0

Record date: 4 October 2026.

| Stage | Technical change | Recorded outcome |
|---|---|---|
| v1.0.0 baseline | Console service installation/removal and local catalogue | Historical owner-reported Windows acceptance in the earlier archive |
| Interactive installation preparation | Setup window, free-port selection, confirmed IIS option and IP links | PowerShell parsing, ten mocked port/IIS assertions and six catalogue tests passed |
| Interactive removal preparation | Keep files/Delete everything/Cancel window, external runner/logs and ownership checks | Seven PowerShell files parsed; six mocked removal-engine tests passed |
| Owner Windows acceptance | Owner tested the interactive tools on their PC | Owner reported that everything passed; confirmation received 4 October 2026 |
| v1.1.0 finalisation | Pre-release labels removed; metadata, technical records and guide footers updated | Runtime behaviour retained; final ZIP/checksums and guide layouts verified during packaging |

## Preparation removal tests

- Keep files removed the mocked owned service/rules and preserved the resource file; ownership status was updated.
- Delete everything removed the disposable owned directory and reported successful deletion.
- Cancellation caused no service/rule/file changes.
- An ownership-folder mismatch stopped removal before mutation.
- A different service application stopped removal before mutation.
- An unrelated firewall-rule name stopped removal before mutation.

These checks ran under PowerShell 7.4.6 on Linux. They do not constitute native Windows Forms or actual service/firewall execution. The owner's separate Windows report provides the acceptance record; individual outputs and machine details were not supplied with that report.

The final distribution includes matching sources, guides, notices and SHA256SUMS.txt. Optional Kiwix/reverse-proxy Windows execution remains outside the preparation record.
