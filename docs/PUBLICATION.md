# Publish Offline Learning Portal v1.1.0

The final package contains the owner-accepted interactive installation/removal tools, source files, guides, notices and SHA256SUMS.txt. Retain the exact final archive.

## GitHub

Upload the extracted Offline_Learning_Portal folder contents at the existing repository root, preserving subfolders and publication metadata. Create a new release tagged v1.1.0 from main after uploading the final files. Use GITHUB_RELEASE.md as the release description. Attach Offline_Learning_Portal_v1.1.0.zip and its archive checksum file. Mark this as the latest release. Retain the earlier v1.0.0 tag/release.

## Zenodo

Open https://zenodo.org/records/23120387 and choose New version. Set version 1.1.0 and publication date 2026-10-04, review the inherited creator/software/licence metadata and upload the identical v1.1.0 ZIP. Remove any older ZIP imported into this new draft. Publish to obtain this version's DOI. Retain the earlier archive and DOI as the v1.0.0 record.

The old DOI 10.5281/zenodo.23120387 identifies v1.0.0. Do not use it as the DOI for v1.1.0. After publishing, add the new DOI to the GitHub release description and manuscript citation. The final CFF identifies v1.1.0 using its GitHub release URL; the package does not guess an unassigned DOI. Adding a DOI to an external release description does not change the archive or its hashes.

If GitHub-to-Zenodo integration is enabled and automatically creates the v1.1.0 record, use that resulting version rather than making a duplicate manual deposit.

## Verify the archive

Download the uploaded ZIP and compare its SHA-256 hash with ARCHIVE_SHA256.txt. Extract it and verify SHA256SUMS.txt against the packaged files; the manifest excludes itself. GitHub's generated source archives use the tag commit, so create the new tag only after the final source upload. A changed file requires new hashes and a rebuilt archive.
