# Offline Learning Portal — v1.0.0
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23120387.svg)](https://doi.org/10.5281/zenodo.23120387)

A small Windows school portal: NGINX serves a local catalogue and three illustrated user guides. NSSM runs NGINX automatically as a Windows service. Schools can add their own permitted resources without adopting the original portal's folder names or collections.

## First installation
1. Extract this ZIP into a working folder. This is a new installation; do not run it over your working portal.
2. This testing copy already includes your supplied NGINX and NSSM executables, plus the NGINX configuration support files from your supporting ZIP. No separate executable download is needed for this test. See docs/DEPENDENCIES.md for provenance and publication notes.
3. Edit portal-settings.json before installation. Default destination is C:\LearningPortal, hostname Portal, HTTP port 80. Use a dedicated destination without spaces. Choose a unique school computer name (maximum 15 characters). A hostname alone does not configure DNS.
4. Right-click Install.bat and select Run as administrator. Review the printed destination, service and firewall settings, then type YES. Installation refuses an existing destination, service or named firewall rules. An occupied port offers an alternative; existing services are not stopped.
5. The script checks NGINX configuration, registers OfflineLearningPortal with automatic start and restart after application exit, adds firewall rules, starts the service, and checks the local catalogue. If offered a computer rename, type RENAME only if appropriate; otherwise press Enter. Renaming a domain-managed machine should be coordinated with its administrator. A rename requires a Windows restart.
6. Open http://localhost/ on the server. On another school device, open http://SERVER-IP/ and, if name resolution works, http://Portal/. Replace Portal with the actual computer name. For a non-80 port append :PORT to all URLs.
7. Restart Windows and repeat both local and client checks. The runtime baseline was exercised on Windows by the owner; this exact v1.0.0 archive needs a review test before publication; docs/VALIDATION.md distinguishes supplied evidence from unrecorded individual checks.

## Add school resources
In the installed portal, copy permitted files into C:\LearningPortal\web\resources\category-name (adjust for your install directory), optionally add metadata sidecars, and run Rebuild_Catalog.bat. Python 3 is required only for rebuilding the catalogue. Initial browsing and installation need no Python. See docs/TAILORING.md for HTML activities, PDFs, media and optional integrations.

## Package layout
| Folder/file | Purpose |
|---|---|
| web/ | Offline home page, catalogue and school resources |
| scripts/ | Windows setup/uninstall; Python catalogue generator and PDF guide source |
| portal-settings.json | Installation settings |
| vendor/ | Bundled NGINX, NSSM and upstream notices |
| docs/ | Dependencies, tailoring, operations and validation |
| tests/ | Portable catalogue tests |

The baseline has one web service. Kiwix is an optional additional service, not required for the main portal. NSSM is a service wrapper, not a scraper; this package does not scrape web content. Back up resources and verify permission to host them. The free MIT licensing plan is documented in LICENSE_STATUS.md.


## Release documentation
This v1.0.0 release consolidates the owner's accepted runtime baseline with documented tests, original-file MIT licensing and matching upstream dependency notices. Review RELEASE_NOTES.md, LICENSE.txt, THIRD_PARTY_NOTICES.md and docs/TEST_HISTORY.md. Run the installed Uninstall.bat to choose preservation or full deletion. Legacy rollback is kept separately. Occupied-port handling offers an alternative without stopping existing services.

## Included user guides
1. Setup and Access (4 pages): installation, access, checks, removal and finding the live files.
2. Add and Organise Resources (10 pages): an original local lesson built with Explorer and Notepad; complete HTML, CSS, JavaScript, optional media and Python exercises.
3. Kiwix and Advanced Resources (10 pages): official software/ZIM download steps, directory creation, manual testing, scoped firewall rule, separate NSSM service, navigation, maintenance and removal.

Read the PDFs through the catalogue. Full editable Markdown and canonical guide data are in docs/guide_sources. To regenerate PDFs, install Python 3 and ReportLab and run `python scripts/build_user_guides.py`; use --font-dir for alternative font locations. Edit guides.json for PDF content and keep Markdown companions in sync.

## Ready-made fresh lesson
Copy examples/lesson-starter into the installed web/resources/Activities folder, or follow Guide 02 to create every file yourself. The lesson and its answer button work without media downloads. Optional media is teacher supplied with permission. The separate Python media list is optional; the main catalogue uses Rebuild_Catalog.bat. No code from the author's prior portal is reused in this new lesson.

The optional Kiwix instructions have not been executed on Windows during preparation; test them separately. Its server is not bundled or automatically installed. Advanced reverse proxy instructions are a separate appendix and are unnecessary for the beginner direct-port setup.

To update existing guides, back up the installed web folder, replace only these three PDFs and their metadata, and rebuild the installed catalogue. Keep school resources. Service reinstallation is unnecessary for content edits. Review docs/PUBLICATION.md before GitHub/Zenodo publication.

## Creator and contact
Tirtharaj Dhungana - [tirtharajdhungana84@gmail.com](mailto:tirtharajdhungana84@gmail.com). Original project files, manuals and lesson examples are MIT licensed. Third-party components and teacher-added content retain their own terms.

## Final publication package
Upload Offline_Learning_Portal_v1.0.0.zip to a Zenodo software record. For GitHub, put the extracted package contents at the repository root, tag the release v1.0.0, and attach this ZIP. The ready-made lesson is included in examples/lesson-starter; no separate example download is required. See docs/PUBLICATION.md and docs/GITHUB_RELEASE.md. No public deposit has yet been made.

## Acknowledgements

ChatGPT (OpenAI), including its Codex tools, assisted with code and script drafting and revision, documentation, guides, examples, troubleshooting, and release preparation. Tirtharaj Dhungana directed and reviewed the work and performed the Windows deployment tests reported in the validation record. Responsibility for the release remains with the project creator. See [ACKNOWLEDGEMENTS.md](ACKNOWLEDGEMENTS.md) for details.
