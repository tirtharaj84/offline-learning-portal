# Windows acceptance checks for interactive setup

Status: owner-reported Windows acceptance passed; confirmation received 4 October 2026. The following procedures are retained for reproduction. Individual results/logs were not supplied with the overall confirmation.

Use a spare Windows computer or a dedicated test configuration. Retain the ZIP hash, Windows build, settings and setup output.

1. Extract to a path with spaces; double-click Install.bat. Cancel UAC and confirm no installation occurs. Run again and accept UAC.
2. Check layout at normal and increased display scaling; verify keyboard navigation, coloured buttons and status text.
3. Install to a new destination using an available port. Verify NGINX configuration, running NSSM service, HTTP firewall scope and local catalogue.
4. Select the actual school-network address, copy its link and open it on a phone on the same LAN. Test a non-80 port too.
5. Restart Windows and verify automatic portal access. Recheck any IIS/port conflict after restart.
6. Occupy the chosen port with another application. Use available port and confirm that application stays available. Also occupy the port after the window check but before installation: the engine must stop rather than reassign silently.
7. On a test IIS installation, check the active HTTP binding on port 80. Decline the interruption prompt and verify no changes. Accept it, verify W3SVC stops and the port is checked again. Do not stop shared HTTP/WAS services to force release.
8. Test a case where port 80 remains occupied after stopping IIS; verify IIS restoration and the alternate-port message. Test cancellation after successful temporary stopping; verify IIS restoration.
9. If installing successfully after an IIS stop, confirm the ownership record says IIS was stopped. Verify its startup/bindings remain unchanged. Resolve the binding before restoring IIS or restarting Windows.
10. Verify existing destinations/services/firewall names are refused, partial failure logs are available, and installed uninstall options still preserve or delete only the owned portal.

IIS service restoration after a successful installation is an administrator action after resolving bindings. The uninstall script does not automatically restore IIS. A selected IP can change if assigned by DHCP; use a school-managed DHCP reservation when a stable address is needed.

Record actual results; do not mark unchecked items as passed.


## Interactive removal checks

11. Run Uninstall.bat from the installed test folder. Cancel UAC and verify no removal starts; accept UAC on a later run. Confirm the window shows the correct folder/service.
12. Click Cancel and reopen. Confirm files, service and firewall rules remain unchanged.
13. Choose Keep files, decline confirmation, and verify no changes. Accept it on a later attempt; confirm service/rules are absent and resources remain.
14. Use a separate fresh test installation for Delete everything. Decline confirmation first. After backing up outside the destination, accept deletion and verify the service, rules and directory are absent. The GUI should remain responsive and display its result.
15. Review the external removal log after deletion. Test a locked resource file and verify incomplete deletion is reported as an error.
16. Test attempts to close while removal runs. Verify closing is blocked until completion.
17. In disposable test copies, alter ownership/root/service-path/rule-name records and verify no unrelated application or firewall rule is removed.
18. Verify both removal options leave IIS startup/bindings unchanged. Restore IIS manually only after resolving the port conflict.

## Preparation results

Seven PowerShell files parsed under PowerShell 7.4.6 on Linux. Ten mocked port/IIS assertions, six catalogue tests and six mocked removal-engine tests passed. Package JSON and the four-page Guide 1 layout were checked. These preparation checks do not independently reproduce native Windows UI, elevation, services/firewall/IIS or Windows file-lock behaviour; owner acceptance is recorded separately. The final v1.1.0 package includes SHA256SUMS.txt.
