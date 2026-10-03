# Included dependencies

The supplied NGINX 1.30.1 and NSSM 2.24 win64 executables are already in vendor paths. Each matches the corresponding executable in the official distribution archive byte for byte. Download URLs/archive hashes/comparison results are in vendor/PROVENANCE.json. Original notices are retained under vendor/nginx/docs and vendor/nssm-notices. No additional executable download is needed for the included Windows testing setup.

The installer generates portal.conf and creates logs and temporary directories. Python 3 is required only to regenerate the catalogue; ReportLab only to recreate guide PDFs. Administrative rights and Windows PowerShell 5.1 are required for installation/uninstallation. NSSM stays inside the installation and defaults to LocalSystem.

Consult https://nginx.org/en/docs/windows.html and https://nssm.cc/download for version/Windows limitations. A preserved successful test build does not guarantee compatibility with every other computer. The provider advises newer NSSM builds for some newer Windows systems; consider a separately tested upgrade for future releases rather than assuming this 2.24 binary is universally suitable.
