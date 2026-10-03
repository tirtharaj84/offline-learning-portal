# Manuscript implementation note

## Suggested descriptive passage
The Offline Learning Portal was implemented as a Windows-hosted static resource catalogue served by NGINX. NSSM managed the web server as a Windows service with automatic startup and configured restart behaviour. The release supplies three novice user manuals and original lesson examples and a Python catalogue generator, while allowing schools to add resources they were permitted to host. Installation applied inbound firewall rules scoped by network profile and remote address. Clients accessed the portal through the server's IP address; hostname access depended on computer naming and network name resolution.

During iterative testing, an installation-path validation error and missing NGINX temporary-directory parent were identified and corrected. The project owner subsequently reported successful installation and local catalogue availability, access from mobile and other devices over the test LAN, and complete removal through the uninstall script. Console outputs supported the configuration, service and deletion observations. These results demonstrate functional deployment in the reported environment and do not constitute an evaluation of learning outcomes or a performance benchmark.

## Reporting notes
- Name the candidate version 1.0.0 in review materials. The v1.0.0 archive is prepared; add its public repository/DOI when deposited.
- Identify tester(s), Windows build, hardware, browsers, client count, network arrangement and dates from actual records.
- Cite the versioned archived software artifact once available. No DOI, repository URL or manuscript author list has been assigned here.
- Distinguish configured automatic restart from an explicitly exercised reboot/failure test.
- Describe internet-disconnected testing only when recorded; LAN access alone does not demonstrate every external dependency is local.
- State optional Kiwix, Epaath and 3D integration as extensibility guidance, not implemented baseline features.
- If required by the journal, disclose AI assistance accurately: Codex assisted with the starter code, illustrated user guides, documentation and iterative revisions; the owner performed Windows testing and reviewed behaviour. Follow the actual journal policy.
