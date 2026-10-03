# Offline Learning Portal — v1.0.0

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23120387.svg)](https://doi.org/10.5281/zenodo.23120387)

A Windows-based school LAN site for serving a catalogue of locally stored learning resources. NGINX serves the portal and files; NSSM runs NGINX as a Windows service. A browser on the server or an allowed device on the school network can open the catalogue.

## Core operation

- **Local web hosting:** Bundled NGINX serves the portal over HTTP. The default port is 80.
- **Windows service:** Bundled NSSM registers the NGINX process as `OfflineLearningPortal`, starts it automatically with Windows and restarts it after an application exit.
- **Resource catalogue:** A Python 3 script scans the local `web/resources` directory and builds `web/catalog.json`. Python is needed to rebuild the catalogue, not to install or browse the supplied portal.
- **Supported catalogue files:** PDF, MP3, WAV, M4A, OGG, MP4, WEBM, HTML and HTM. HTML entry pages require a `.meta.json` sidecar to be listed. Their CSS, scripts, images and other dependencies must be included and referenced correctly by the activity itself.
- **Resource details:** Optional sidecars provide title, category, language, source, rights and description. Without a sidecar, the catalogue derives the title from the filename and category from its folder; it does not infer language or rights.

The portal serves files to network clients allowed by the configured firewall. Do not put confidential records in `web/resources`. Confirm permission to host every resource. Browser support for media formats varies.

## Install

1. Extract the release ZIP into a working folder. Use a dedicated destination; the installer refuses to overwrite an existing destination.
2. Edit `portal-settings.json`. Defaults are `C:\LearningPortal`, hostname `Portal`, service `OfflineLearningPortal`, and HTTP port 80. The configured hostname does not create DNS or guarantee that clients can resolve it.
3. Right-click `Install.bat` and choose **Run as administrator**. Review the destination, port, service and firewall scope. Type `YES` to continue.
4. If the selected port is occupied, choose an available alternative or cancel. The installer does not stop existing services.
5. On the server, open `http://localhost/`. From another device on the school LAN, open `http://SERVER-IP/`. If name resolution is configured, the hostname URL may also work. For a non-80 port, append `:PORT` to the address.
6. Follow the setup guide to check access, restart behaviour and removal options.

The installer configures inbound firewall rules from `portal-settings.json`; review these settings for the school network before confirming. Computer renaming is optional and may require a restart.

## Add or update resources

Copy permitted files into a category folder under `web/resources`, for example `web/resources/Science`. To add catalogue details, create a matching sidecar such as `fractions.pdf.meta.json`. Run `Rebuild_Catalog.bat` to regenerate the catalogue, then refresh the page. See [`docs/TAILORING.md`](docs/TAILORING.md) for metadata format, HTML activities and supported content workflows.

The catalogue generator does not install content or repair an activity's missing dependencies. HTML files are listed only when registered with a sidecar. Back up resources before maintenance.

## Technical scope and limits

The baseline is one NGINX web service and a static JSON catalogue. It has no browser-based administration or upload panel, user accounts, learner tracking or automated assessment. Kiwix/ZIM hosting is an optional separate service described in the guides; the installer does not install or configure it.

## Package map

| Path | Contents |
|---|---|
| `web/` | Portal pages, styles, catalogue and example resources |
| `scripts/` | Windows installation/removal and Python catalogue/guide tools |
| `portal-settings.json` | Install path, hostname, port, service and firewall settings |
| `vendor/` | NGINX, NSSM and upstream notices/provenance |
| `docs/` | Setup, dependencies, tailoring, operations and validation records |
| `tests/` | Portable catalogue tests |

## Guides and validation

The package includes guides for setup and access, adding resources, and optional Kiwix configuration. The baseline Windows deployment was tested by the project owner. Package preparation checks and the limits of the recorded evidence are documented in [`docs/VALIDATION.md`](docs/VALIDATION.md) and [`docs/TEST_HISTORY.md`](docs/TEST_HISTORY.md). Optional Kiwix/ZIM and reverse-proxy procedures were not executed as part of the recorded Windows baseline.

## Licence and citation

Original portal files and guides are MIT licensed. Third-party components and school-added materials retain their own terms; see [`LICENSE.txt`](LICENSE.txt), [`LICENSE_STATUS.md`](LICENSE_STATUS.md) and [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

- GitHub repository and release: https://github.com/tirtharaj84/offline-learning-portal
- Zenodo version DOI: https://doi.org/10.5281/zenodo.23120387
- Creator: Tirtharaj Dhungana — tirtharajdhungana84@gmail.com

