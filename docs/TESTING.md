# Testing and validation

## Baseline inventory

The audited repository contains no `FreeTubeTests` directory, XCTest target, or test scheme. Therefore no automated tests were run or passed during source audit. The manual workflow skips XCTest explicitly if the project still has no unit-test target; it does not mark skipped tests as passing.

## CI commands

The `.github/workflows/ios-build.yml` workflow runs on development-branch pushes and supports manual dispatch. It:

```sh
xcodebuild -list -json -project FreeTube/FreeTube.xcodeproj
xcodebuild -resolvePackageDependencies -project FreeTube/FreeTube.xcodeproj -scheme FreeTube
xcodebuild build -project FreeTube/FreeTube.xcodeproj -scheme FreeTube -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
xcodebuild build -project FreeTube/FreeTube.xcodeproj -scheme FreeTube -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO
```

If an XCTest target is later added, CI runs `xcodebuild test` on an iPhone 17 simulator. Build/test logs are artifacts.

## Required automated coverage

Add unit tests for cookie-domain selection and missing-cookie behavior without real credentials; Keychain wrapper error handling via an injectable interface; logout clearing state; search mapping and pagination; local cache eviction; queue ordering and resume positions; playback resolver fallbacks; download errors/cancellation; audio interruption event handling; and UI loading/empty/error states using mocks.

Never put real cookies, account credentials, signed media URLs, or private user content in fixtures. Mock network responses and keep logs redacted.

## Device-only checks

A real iPhone is required to validate signed installation, PiP and background transitions, lock-screen controls, AirPods/Bluetooth reconnection, AirPlay, phone/audio interruptions, resume, and thermal/battery/data behavior. None of those checks has been executed yet.
