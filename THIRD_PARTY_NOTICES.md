# Third-party notices

The project MIT licence covers the original portal files. Vendor software retains its upstream terms.

## NGINX

NGINX 1.30.1: the supplied binary was recorded as byte-identical to nginx-1.30.1/nginx.exe in the official Windows archive. Upstream documentation and notices are retained under vendor/nginx/docs in the source package and runtime/nginx/docs in a fresh installation. These include LICENSE, OpenSSL.LICENSE, PCRE.LICENCE and zlib.LICENSE.

## NSSM

NSSM 2.24, win64: the supplied binary was recorded as byte-identical to nssm-2.24/win64/nssm.exe in the official archive. The provider states that NSSM is public domain. Upstream README and ChangeLog files are retained under vendor/nssm-notices in the source package and runtime/nssm-notices in a fresh installation.

## Provenance and compatibility

SHA-256 comparison records, archive URLs and retrieval dates are in vendor/PROVENANCE.json in the source package. The corrected installer copies that record to runtime/PROVENANCE.json. The recorded check was byte equality; it did not include PGP/signature verification or execution of the binaries in the preparation environment.

NGINX configuration support files were supplied by the creator. Their upstream notices are retained. No school content collection or external JavaScript framework is included.

The bundled executable bytes remain those of the owner-tested baseline. The NSSM provider recommends a newer prerelease/build for some newer Windows configurations; see https://nssm.cc/download. This package retains the tested 2.24 build for reproducibility. Successful execution on the owner's machine does not establish compatibility with every Windows version.

## Separately installed tools and content

Python and ReportLab are separately installed tools, not bundled dependencies. Catalogue generation uses Python's standard library. Recreating the PDF guides requires ReportLab.

School-added resources, external media and ZIM collections require their own licences or permission records. The project's MIT licence does not grant permissions for those materials.
