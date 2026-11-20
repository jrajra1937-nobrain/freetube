# Repository guidance

- Read `CLAUDE.md` before changing application code; it documents important concurrency, playback, cookie, and FFmpeg constraints.
- Keep upstream MIT attribution and `LICENSE` intact.
- Preserve the iOS 17 deployment target unless the user approves a change.
- Never log cookie values, passwords, authorization headers, or signed media URLs. Keep session secrets in the iOS Keychain.
- Do not bypass YouTube access controls, age restrictions, account restrictions, or content protections. Describe playback as conditional on service and content access.
- Make focused changes and preserve the existing SwiftUI/MVVM/service architecture where it is functional.
- Run the manually dispatched `.github/workflows/ios-build.yml` after changes that affect the Xcode build. Do not state that a build or test passed unless its run completed successfully.
- There is currently no XCTest target in the upstream baseline. Add focused tests before claiming test coverage.
- User interface redesign is deferred until the upstream baseline has a confirmed CI build.
