# Installation (planned, Windows 11 ARM64 + iPhone 13)

## Current status

No signed IPA or device installation has been produced. The CI workflow produces an **unsigned** IPA; it is not installable until AltServer/AltStore (or another legitimate signer) signs it for the user's Apple account/device.

As of 2026-11-20, AltStore announced official Windows on ARM support in AltServer 1.8. Its Windows guide still requires Windows 64-bit iTunes and iCloud components from Apple, so the exact Apple driver/dependency behavior on this Snapdragon machine remains to be confirmed during installation. AltStore documents its direct Windows sideload procedure. Apple's free Personal Team limits include 10 App IDs and 3 devices, with registrations and provisioning profiles expiring after 7 days; a free-signed app therefore needs renewal/reinstallation at least weekly.

## Expected flow after a successful CI build

1. Push to `dev/personal-edition` to start the build, or use **Actions → iOS build → Run workflow** when the workflow is available in the default branch. The workflow uploads an unsigned IPA and build logs.
2. On Windows ARM64, install the current official AltServer 1.8 or later and AltStore Classic from the official project source. AltStore announced ARM support on 2026-09-14. Follow its Windows setup guide, which asks for iTunes and iCloud from Apple (not Microsoft Store) and device trust/Wi-Fi sync. Confirm Apple driver installation and iPhone detection on this Snapdragon PC before continuing.
3. Sign the IPA using a legitimate free Apple ID workflow supported by the chosen sideload tool. Never upload Apple credentials or signing certificates to this repository or CI.
4. Install AltStore on iPhone using its official Windows process, then install the signed app from AltStore.
5. If iOS requests Developer Mode for development-signed apps, enable it only through iOS Settings and follow Apple's restart/confirmation flow.
6. Verify the app opens and media behavior with permitted test media. Re-sign/reinstall on the cadence required by the free account/tool.

Official references:

- [AltStore: Windows on ARM announcement](https://bsky.app/profile/altstore.io/post/3mviuzdvbgc2q)
- [AltStore: install AltStore on Windows](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)
- [AltStore: AltServer release notes](https://faq.altstore.io/release-notes/altserver)
- [Apple: Personal Team limits and provisioning validity](https://developer.apple.com/help/account/basics/about-your-developer-account/)

The Windows ARM support claim is verified from AltStore's announcement, but this project has not installed AltServer on the user's particular laptop. Do not disable Windows security features or iOS protections.

## Required future validation

Record exact AltServer version, Windows ARM64 support, driver prerequisites, signing tool/version, Apple account signing validity, Developer Mode steps, and renewal procedure only after checking current official documentation. The user must perform the physical phone trust/install actions and any account authentication themselves.
