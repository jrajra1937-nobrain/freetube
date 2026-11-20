# Project progress

Updated: 2026-11-20

## Overall: 12% (Figma phase validated; audit and build remain in progress)

The user-specified weighted milestones are based on completed evidence. The Figma milestone is validated at 10%; the source audit has roughly 20% of its 10% weight completed (2%). The build workflow is configured and published to the connected fork, but has not executed. GitHub currently has no workflow on the fork's default branch, and the GitHub connector does not expose the workflow-dispatch operation.

| Milestone | Weight | Status | Evidence |
|---|---:|---|---|
| Repository audit | 10% | In progress | Clone and commit fixed; source tree and project inspected; full audit remains |
| Original compilation | 15% | Not validated | CI workflow added but not run; `xcodebuild` unavailable in current Linux environment |
| iPhone installation | 15% | Not started | No signed IPA or physical device access |
| Player validation | 15% | Source only | AVFoundation components found; no iPhone runtime tests |
| Authentication/security | 10% | Initial review only | Cookie flow and official OAuth feasibility compared; deeper audit and account-safe decision outstanding |
| Design Figma | 10% | Complete | Connected Figma file contains 14 iPhone frames, editable color/layout variables, reusable components, and loading/empty/error/success states |
| SwiftUI integration | 15% | Not started | Existing UI retained; custom design deferred until baseline compile |
| Tests and delivery | 10% | Not started | No XCTest target or artifact run |

## Completed this turn

- Cloned the upstream repository and fixed reference at `8fc6d3b7be9571e3ffcb179de3d1de2dfe7012e7`.
- Inspected README, CLAUDE.md, LICENSE, integration guide, Xcode project, package lockfile, source tree, authentication/player entry points, and unfinished methods/TODOs; checked upstream issue tracker, dated dependency pins, and official Google OAuth/Data API documentation.
- Added a manually dispatched GitHub Actions workflow for package resolution, conditional tests, simulator/device builds, unsigned IPA packaging and log artifacts.
- Created the Figma design file with 14 iPhone screens, editable variables, reusable components and four UI states.
- Published the audit, documentation and manual build workflow to `jrajra1937-nobrain/freetube` on `dev/personal-edition`; verified the remote branch and workflow file.
- Added repository guidance and initial architecture/install/security/Figma/testing/maintenance documentation; verified official AltStore Windows ARM announcement and Apple free Personal Team limits.

## Outstanding

- Make the workflow available from the repository default branch (GitHub requires a `workflow_dispatch` workflow there before it can be run against a development branch), then manually dispatch it; current workspace has no Xcode.
- Integrate Figma components into SwiftUI only after the baseline build is confirmed.
- Complete source-level audit of all code and package/license/security/update concerns.
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
- XCTest target: none present in audited baseline.

## User actions eventually needed

- Merge or copy `.github/workflows/ios-build.yml` to the fork's default branch, then dispatch it for `dev/personal-edition` in GitHub Actions (the connected GitHub tool has no workflow-dispatch action).
- Perform Apple account sign-in, sideload authorization, and physical iPhone validation.
