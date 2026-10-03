# Third-party notices

The project MIT licence covers the original portal files, not vendor software.

- NGINX 1.30.1: supplied binary exactly matches nginx-1.30.1/nginx.exe in the official Windows archive. Complete upstream docs are retained under vendor/nginx/docs, including LICENSE, OpenSSL.LICENSE, PCRE.LICENCE and zlib.LICENSE.
- NSSM 2.24, win64: supplied binary exactly matches nssm-2.24/win64/nssm.exe in the official archive. Upstream README and ChangeLog are retained under vendor/nssm-notices. The provider states NSSM is public domain.
- SHA-256 comparison records, archive URLs and retrieval dates are in vendor/PROVENANCE.json. Byte equality is the check performed; no PGP/signature verification or Windows execution was performed here.
- NGINX configuration support files were supplied by the owner. Their upstream NGINX notices are retained. No school content collection or external JavaScript framework is included.
- Python and ReportLab are separately installed tools, not bundled dependencies. Catalogue generation uses Python standard library; recreating PDFs requires ReportLab.

This release preserves the tested executable bytes. The NSSM provider recommends a newer prerelease/build for some newer Windows configurations; see https://nssm.cc/download. This release retains the owner's successful tested 2.24 build for reproducibility rather than silently changing it. Success on the owner's machine is not a compatibility guarantee on other Windows versions.
