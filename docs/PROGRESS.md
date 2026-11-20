# Project progress

Updated: 2026-11-20

## Overall: 15% (Figma phase validated; security hardening in progress; build unvalidated)

The user-specified weighted milestones are based on completed evidence. Figma is validated at 10%; repository audit is approximately 50% complete (5%). Source-level security hardening contributes no separate weight until the security milestone is fully audited. The build workflow is configured but has not executed. No iPhone installation or media validation is claimed.

| Milestone | Weight | Status | Evidence |
|---|---:|---|---|
| Repository audit | 10% | In progress | Baseline pinned; core project, auth, player, persistence, Xcode config, packages and workflow inspected; complete dependency and runtime audit remains |
| Original compilation | 15% | Not validated | CI workflow added but not run; `xcodebuild` unavailable in current Linux environment |
| iPhone installation | 15% | Not started | No signed IPA or physical device access |
| Player validation | 15% | Source only | AVFoundation components found; no iPhone runtime tests |
| Authentication/security | 10% | In progress | Risky cookie-capture login disabled; Keychain error handling and YouTube cookie scoping hardened; logging minimized; source/runtime audit remains |
| Design Figma | 10% | Complete | Connected Figma file contains 14 iPhone frames, editable color/layout variables, reusable components, and loading/empty/error/success states |
| SwiftUI integration | 15% | Not started | Existing UI retained; custom design deferred until baseline compile |
| Tests and delivery | 10% | Not started | No XCTest target or artifact run |

## Completed this turn

- Cloned the upstream repository and fixed reference at `8fc6d3b7be9571e3ffcb179de3d1de2dfe7012e7`.
- Inspected README, CLAUDE.md, LICENSE, integration guide, Xcode project, package lockfile, source tree, authentication/player entry points, and unfinished methods/TODOs; checked upstream issue tracker, dated dependency pins, and official Google OAuth/Data API documentation.
- Added a GitHub Actions workflow for package resolution, conditional tests, simulator/device builds, unsigned IPA packaging and log artifacts. It supports manual dispatch and runs on pushes to `dev/personal-edition`.
- Created the Figma design file with 14 iPhone screens, editable variables, reusable components and four UI states.
- Published the audit, documentation and manual build workflow to `jrajra1937-nobrain/freetube` on `dev/personal-edition`; verified the remote branch and workflow file.
- Blocked Google cookie-capture login in the app UI pending official OAuth/API implementation; public-content use stays available.
- Hardened Keychain write/delete handling and exact YouTube cookie-domain checks; removed several sensitive cookie and signed-URL log paths.
- Disabled raw diagnostic-file export because source logs can contain private identifiers or signed stream URLs; UI explains the limitation.
- Added repository guidance and initial architecture/install/security/Figma/testing/maintenance documentation; verified official AltStore Windows ARM announcement and Apple free Personal Team limits.

## Outstanding

- Publish the current security changes and wait for the first CI run; current workspace has no Xcode.
- Integrate Figma components into SwiftUI only after the baseline build is confirmed.
- Complete source-level audit of all code and package/license/security/update concerns; remaining path/title/identifier logs need review.
- Resolve compile failures found by CI before any visual redesign.
- Decide how to handle cookie-based Google login; do not use a primary account yet.
- Implement focused XCTest coverage after baseline compilation.
- Verify current official sideload, Windows ARM64 and Apple free-signing requirements before installation.
- Validate media behavior on the actual iPhone 13.

## Changed files

- `.github/workflows/ios-build.yml`
- `AGENTS.md`
- `docs/ARCHITECTURE.md`
- `docs/INSTALLATION.md`
- `docs/SECURITY.md`
- `docs/FIGMA.md`
- `docs/TESTING.md`
- `docs/MAINTENANCE.md`
- `README.md`
- `CHANGELOG.md`

## Test/build results

- `git clone`: completed.
- `xcodebuild`: unavailable on the Linux workspace; GitHub workflow not dispatched yet, so no compile, test, or IPA result is claimed.
- `git diff --check`: pending after the latest edits.
- TLS verification bypass removed from yt-dlp calls; actual embedded CA availability is unknown until macOS CI/device execution.
- The first development-branch update was published through GitHub's Git data API; no Actions run is visible for that commit yet. The build remains unvalidated.
- XCTest target: none present in audited baseline.

## User actions eventually needed

- Review the first CI result and its unsigned IPA artifact. Manual dispatch through GitHub's Actions UI requires the workflow file to be present on the default branch; development pushes already run automatically.
- Perform Apple account sign-in, sideload authorization, and physical iPhone validation.
