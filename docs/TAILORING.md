# Tailor the resources

## PDFs, audio and video
1. Obtain permission to host and distribute the material on the school network. Free access to a website is not automatically permission to copy it. Record the source and licence or permission.
2. Create a meaningful folder under web/resources, such as Science or Teacher resources, then copy files into it. The folder can contain subfolders. Supported catalogue extensions: .pdf, .mp3, .wav, .m4a, .ogg, .mp4, .webm, .html, .htm. Browser format support varies.
3. Optional: beside fractions.pdf create fractions.pdf.meta.json with the following fields (all strings):

```json
{
  "title": "Fractions practice",
  "category": "Mathematics",
  "language": "English",
  "source": "Author or original source URL",
  "rights": "Actual licence or permission details",
  "description": "Short description of the resource"
}
```

4. Run Rebuild_Catalog.bat from the package or installed folder. It requires Python 3 and writes web/catalog.json. On error, correct the reported file and retry; the prior catalogue is preserved. Refresh the portal and open the resource from a second device.

Without metadata, the title derives from the filename and category from the first resource subfolder. Language and rights are not guessed. Spaces and Unicode filenames are URL encoded. Do not use symlinks. Metadata files are hidden by the supplied NGINX configuration, but resource files are public to allowed network clients; do not place confidential school records here.

## Complete HTML activities and Epaath
Place the complete activity folder under web/resources, including CSS, JavaScript, images, fonts, media and any other dependencies. Add a sidecar only for its entry HTML file, for example Epaath/index.html.meta.json. HTML files without a sidecar are not listed individually. Use relative local references and test with internet disconnected. The catalogue includes the entry page; it does not repair broken dependencies. Your existing Epaath folder may be reused if it is complete and its hosting permissions permit it. A single index.html does not establish that all dependencies are present.

## Optional ZIM collections and Kiwix
ZIM files need a compatible Kiwix server; they are not ordinary PDF links and this generator skips them. If wanted, use the official guidance at https://kiwix.org/ and obtain the appropriate server and permitted archives. Register it as a separate NSSM service, use a dedicated loopback port, and configure an NGINX route only after verifying Kiwix URL/base-path requirements for that version. Alternatively expose a separate LAN port with a separately scoped firewall rule. Add navigation links deliberately to web/index.html; the baseline generator does not discover service endpoints. Test all links after restart and from clients. This optional integration is guidance, not implemented automation.

## Optional 3D resources
Raw .glb/.gltf files are not catalogue entries. Supply a complete local HTML viewer, its scripts/decoder assets and model files, and register its entry HTML with a sidecar. Validate browser/WebGL support and offline loading. Do not rely on a CDN for an offline viewer.

## Branding and maintenance
Edit web/index.html and web/styles.css to change the name and appearance. Edit guide metadata or remove guides as needed. Keep backups before editing. Editing files in web requires browser refresh, not service reinstallation. No login, content-management panel, upload interface, scraping or learning progress tracking is included.
