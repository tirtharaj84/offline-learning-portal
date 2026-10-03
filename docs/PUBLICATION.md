# Publication handoff — v1.0.0

Final package prepared for upload; nothing has been published and no DOI has been assigned. Creator: Tirtharaj Dhungana. Original project files and guides: MIT, free to use under its terms. Bundled components retain their upstream notices. Do not imply that the MIT licence covers arbitrary school content or third-party ZIM archives.

## Recommended order: GitHub, then Zenodo
1. Review the three guides and test the exact ZIP on Windows. Record results and retain the SHA256SUMS.txt manifest. Optional Kiwix testing is separate; document it as untested if not exercised.
2. Create a public GitHub repository named `offline-learning-portal`. Upload the extracted package contents at the repository root, including LICENSE.txt, CITATION.cff, .zenodo.json, documentation, notices and sources. Check for school/private data before upload.
3. Before creating the release, connect that repository through Zenodo's GitHub integration and enable archiving. Choose the normal Zenodo service for the actual publication; its sandbox creates test records.
4. Create a GitHub release tagged `v1.0.0`, attach Offline_Learning_Portal_v1.0.0.zip, and use docs/GITHUB_RELEASE.md for the description. Zenodo can archive the release when the integration is enabled. Inspect the resulting record and verify that the intended files, metadata and notices are present.
5. Copy the actual release DOI and public repository URL into CITATION.cff and manuscript references. Cite the specific version DOI when discussing this package; use the concept DOI when referring to the project across versions. Preserve the exact deposited archive.

If GitHub integration is unavailable, upload the reviewed ZIP directly to Zenodo as software, enter the supplied metadata, review the record and publish. This does not create a GitHub repository. Public publication is a separate final step after review.

The included .zenodo.json has the same creator/version/licence as CITATION.cff. Zenodo gives .zenodo.json precedence for GitHub metadata. Update the publication date to the actual release date if it differs from the preparation date. Add genuine contributors only by agreement; software creators and manuscript authors need not be identical.

Official references:
- https://help.zenodo.org/docs/github/archive-software/github-upload/
- https://help.zenodo.org/docs/github/describe-software/
- https://docs.github.com/en/repositories/archiving-a-github-repository/referencing-and-citing-content

Creator contact for the repository description and Zenodo record: tirtharajdhungana84@gmail.com. Reviewed guides are included; optional Kiwix test limits remain recorded. Public upload is performed separately.
