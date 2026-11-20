# Changelog

## Unreleased — personal edition setup

- Fixed upstream audit baseline at `8fc6d3b7be9571e3ffcb179de3d1de2dfe7012e7`.
- Added a manually triggered GitHub Actions workflow for dependency resolution, conditional tests, unsigned iOS device/simulator builds, IPA packaging, and build logs.
- Added architecture, security, installation, Figma, testing, maintenance, and progress documentation; recorded unresolved upstream streaming reports and documented official OAuth feasibility and limitations.
- Created the Figma design system, 14 iPhone screen frames, reusable UI components, and loading/empty/error/success states.
- Disabled embedded Google credential and cookie login pending an official OAuth/API path; clear legacy sessions on launch.
- Improved Keychain error handling and cookie host filtering, removed sensitive request URL logging, disabled raw log exports, and restored TLS certificate verification for yt-dlp.
- Updated the development branch workflow to run tests on pushes and manual dispatches.
- Removed alternate player profiles and missing-token format overrides that evaded YouTube Proof-of-Origin checks; playback now fails closed when standard access is unavailable.
- SwiftUI source remains unchanged pending a successful baseline build.
