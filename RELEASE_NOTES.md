# Offline Learning Portal v1.0.0

## Published release

- GitHub release: https://github.com/tirtharaj84/offline-learning-portal/releases/tag/v1.0.0.
- Zenodo version DOI: https://doi.org/10.5281/zenodo.23120387.
- Creator and contact: Tirtharaj Dhungana — tirtharajdhungana84@gmail.com.

## Included components

NGINX serves the local resource catalogue. NSSM runs NGINX as a Windows service. The package includes installation and removal scripts, catalogue generation, bundled dependency executables and notices, editable guide sources, original lesson examples and publication metadata.

The three illustrated guides are Setup and Access (4 pages), Add and Organise Resources (10 pages), and Kiwix and Advanced Resources (10 pages). They cover installation, access, resource organisation, metadata, an original local lesson, optional permitted media and optional Kiwix configuration. The separate reverse proxy appendix is optional.

The example in examples/lesson-starter requires no third-party media for its core lesson and reuses no code from the creator's prior portal. Original project files and guides use MIT; vendor components and school-added content retain their own terms.

## Validation record

Package preparation included six passing catalogue tests, JavaScript syntax checks, temporary HTTP checks, lesson fixture checks, PDF text extraction, inspection of all 24 guide pages and ZIP integrity checks. The creator reported successful Windows deployment and review testing of the published archive. See docs/VALIDATION.md and docs/TEST_HISTORY.md for the results, available evidence and limits of individual records.

Optional Kiwix/ZIM hosting, reverse proxy deployment and specialised viewers were not executed as part of the recorded baseline preparation checks.

## Publication maintenance corrections

The publication documents and release metadata identify the published repository and DOI. The installer includes project licence files, third-party notices, provenance and NSSM upstream notices in the installed directory. Notice documents specify source-package and installed locations.

These notice-copy additions do not change service settings, firewall settings or bundled executable bytes. They have not been executed on Windows in the correction environment and are not included in the historical owner-confirmed test results. Verify their installed file locations when checking this corrected installer.
