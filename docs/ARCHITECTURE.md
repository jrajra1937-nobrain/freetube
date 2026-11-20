# Architecture and repository audit

## Reference baseline

- Upstream: `https://github.com/leshkodev/freetube`
- Branch observed: `main`
- Audited commit: `8fc6d3b7be9571e3ffcb179de3d1de2dfe7012e7` (`Update Localizable.xcstrings`, 2026-07-09)
- License: MIT; retain `LICENSE` and copyright notices in substantial copies.
- Xcode project: `FreeTube/FreeTube.xcodeproj`; target/scheme declared as `FreeTube`; iOS deployment target 17.0.

The audit describes the state at this fixed commit. It is not a claim that the code has built or that YouTube endpoints remain compatible.

## Repository structure

The project uses an Xcode filesystem-synchronized group for `FreeTube/FreeTube`, so the `App`, `Core`, `Features`, `UI`, assets, localization catalog, and bundled JavaScript/resource files are included by folder membership rather than individual PBXBuildFile entries. `FreeTube/FreeTube/ContentView.swift` remains in the synchronized target alongside `RootView.swift`; confirm the actual app entry point in `FreeTubeApp.swift`.

- `App/`: environment and root routing.
- `Core/Auth/`: legacy session cleanup, authentication state, subscription cache.
- `Core/Networking/`: YouTubeKit client and service wrappers/mappers.
- `Core/Player/`: queue, AVPlayer lifecycle, HLS resource loading, lock-screen commands, audio session.
- `Core/Download/`: yt-dlp, FFmpeg, URL downloads and background task scaffolding.
- `Core/Persistence/`: SwiftData models and extended-attribute download metadata.
- `Core/JavaScript/`: JavaScriptCore bridge and bundled JS resources.
- `Features/`: SwiftUI screens and observable view models.
- `UI/`: player surfaces and reusable components.

## Xcode and package dependencies

`Package.resolved` pins YouTubeKit, YoutubeDL-iOS, Python-iOS, PythonKit, FFmpeg-iOS-Support, FFmpeg-iOS-Lame, LNPopupUI/LNPopupController/LNSwiftUIUtils, Kingfisher, KeychainAccess, and SwimplyPlayIndicator. Some packages are pinned to branches (`YouTubeKit main`, `KeychainAccess master`), so the resolved revision is important for repeatability. The lockfile includes dated 2023-era releases for FFmpeg-iOS-Lame (0.0.6-b20230730), Python-iOS (0.1.1-b20230423), and YoutubeDL-iOS (0.0.9), plus FFmpeg-iOS-Support 0.0.2. These are aging pins and need compatibility/security review; their age alone does not prove they are abandoned or replaceable. The project file currently links KeychainAccess while `KeychainHelper.swift` uses `Security.framework` directly; usage of each package should be verified before pruning.

No `.github/workflows` or XCTest target existed in the audited upstream tree. The repository documentation says Xcode 15+, but the project was last upgraded with Xcode 26.2 and uses project-format version 77 plus newer Swift build settings; Xcode 15 compatibility is therefore not established and must not be assumed. The current CI pins Xcode 26.2. The Xcode project file declares one application target and no test target. Local compilation is unavailable in this Linux environment because `xcodebuild` is not installed.

## Features verified in source

- SwiftUI screens exist for home, search/suggestions, subscriptions, account/library/history, channels, playlists, video details/comments, downloads/link fetching, and settings. Account sign-in is not implemented in the Personal Edition.
- `AVQueuePlayer`, `AVPlayerViewController`, audio session, Now Playing metadata, remote command center, and a playback resolver are implemented in source. Hardware PiP, lock-screen playback, Bluetooth/AirPlay behavior, and interruptions still require device validation.
- The upstream cookie login code remains in source but is not reachable from the UI. Session bootstrap clears legacy cookies and sign-in is rejected.
- SwiftData persistence models and background-download coordination are present.
- French entries exist in the string catalog.

## Gaps and discrepancies found

The README status table must not be read as proof of complete functionality. `INTEGRATION.md` explicitly describes service stubs and unfinished integration. Source inspection confirms notable incomplete operations: comment create/edit/delete/reply/rating/translation methods throw `notAuthenticated`; several playlist write operations throw `notAuthenticated`; `SubscriptionService.fetchFeed()` throws `notAuthenticated`; home trending has a TODO; UI actions for comment reply, save-to-playlist, and video download are TODOs; background download completion has a handoff TODO. These should be tested and addressed selectively after a real baseline build.

The `INTEGRATION.md` setup steps about adding folders and SPM packages are stale relative to the current project: the folders are already in a synchronized group and package references/pins are already in `project.pbxproj` and `Package.resolved`.

The upstream WKWebView credential and cookie-capture sources were removed. Session bootstrap clears the legacy Keychain cookie; account sign-in is absent. Official OAuth feasibility depends on supported Google/YouTube APIs and their scopes/quota and is not a drop-in replacement. See `docs/SECURITY.md`.

The project embeds yt-dlp/FFmpeg and offers downloading. The Personal Edition removes alternate player profiles and missing-token format overrides that avoided YouTube's Proof-of-Origin checks. It uses yt-dlp's default extraction policy and the standard iOS player endpoint. Access failures must be shown as failures; do not add fallback profiles that evade restrictions.

## Upstream issue tracker snapshot (2026-11-20)

GitHub currently lists three open issues. Issues #3 and #4 are duplicate reports from 2026-08-29 titled “Video streaming not working”; the reporter says streaming fails most of the time, and one comment points to a fork. Issue #13 (“You top”) has no description, so it is not actionable from the issue body. These are user reports, not reproduced defects at the pinned commit. Track streaming as a known risk and reproduce with permitted media after CI/device setup.

- https://github.com/leshkodev/freetube/issues/3
- https://github.com/leshkodev/freetube/issues/4
- https://github.com/leshkodev/freetube/issues/13

## Compilation baseline status

The audit commit is fixed above. The workflow added in this branch resolves the pinned dependencies, checks the scheme, conditionally runs tests if a test target exists, builds simulator and generic iOS device products without signing, packages an unsigned IPA for later signing, and uploads logs/artifacts. It runs on development-branch pushes and supports manual dispatch. A build result is only claimed after the GitHub Actions run completes.
