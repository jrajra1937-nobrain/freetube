import SwiftUI

@available(iOS 17.0, *)
struct SettingsScreen: View {
    @State private var model = SettingsViewModel()
    @State private var showingResetConfirmation = false

    /// Drives the live cache-usage line under the download cache limit picker. The store is
    /// `@Observable`, so reading `entries` here re-renders the view when downloads land or
    /// the cache eviction sweep deletes files.
    @State private var downloads = DownloadsStore.shared

    private var currentCacheBytes: Int64 {
        downloads.entries.reduce(0) { $0 + $1.fileSize }
    }

    private var formattedCacheUsage: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: currentCacheBytes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Preferred quality", selection: Bindable(model).preferredQuality) {
                        ForEach(VideoQuality.allCases) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                    Toggle("Autoplay next video", isOn: Bindable(model).autoplayNext)
                } header: {
                    Text("Playback")
                } footer: {
                    Text("Videos download to your device before playback. Lower qualities save space and download faster.")
                }

                Section("Search") {
                    Toggle("Restricted search mode", isOn: Bindable(model).restrictedSearchMode)
                }

                Section {
                    Toggle("Allow cellular data", isOn: Bindable(model).allowCellularDownloads)
                    Toggle("Prefetch next video", isOn: Bindable(model).prefetchNextInQueue)
                    Picker("Cache limit", selection: Bindable(model).downloadCacheLimit) {
                        ForEach(DownloadCacheLimit.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    Picker("Parallel fragments", selection: Bindable(model).concurrentFragments) {
                        ForEach([1, 2, 4, 8, 16], id: \.self) { value in
                            Text(value == 1 ? "1 (sequential)" : "\(value)").tag(value)
                        }
                    }
                } header: {
                    Text("Downloads")
                } footer: {
                    Text("Currently using \(formattedCacheUsage). When the cache exceeds the limit, the oldest downloads are removed to fit.\n\nPrefetch starts a background download of the next queued video as soon as the current one plays, so tapping Next is instant. Turn off to save bandwidth.\n\nParallel fragments controls how many HLS/DASH chunks yt-dlp fetches at once inside a single download — higher values are faster on good connections; values above 8 can trigger YouTube rate-limiting.")
                }

                Section {
                    LabeledContent("Version") {
                        Text(model.ytDlpVersion.isEmpty ? "Not yet loaded" : model.ytDlpVersion)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    LabeledContent("Last updated") {
                        Text(model.ytDlpLastUpdatedDisplay ?? "Never")
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        model.updateYtDlpNow()
                    } label: {
                        HStack {
                            Label("Update now", systemImage: "arrow.down.circle")
                            if model.isUpdatingYtDlp {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(model.isUpdatingYtDlp)

                    if let status = model.ytDlpUpdateStatus {
                        switch status {
                        case .success(let version):
                            Label("Updated to \(version)", systemImage: "checkmark.circle")
                                .foregroundStyle(.green)
                                .font(.footnote)
                        case .noChange(let version):
                            Label("Already at latest (\(version))", systemImage: "checkmark.circle")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        case .failure(let message):
                            Label(message, systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                                .font(.footnote)
                        }
                    }
                } header: {
                    Text(verbatim: "yt-dlp")
                } footer: {
                    Text("yt-dlp is the engine that resolves YouTube stream URLs. FreeTube auto-refreshes it every 7 days from the official GitHub release. Tap Update now if a video stops playing — newer versions often fix breakage caused by YouTube's API changes.")
                }

                Section("Diagnostics") {
                    Label("Anonymized diagnostic export is not available yet.", systemImage: "lock.shield")
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Raw logs can contain account identifiers and temporary media URLs. Local file export is disabled until diagnostics are safely redacted.")
                }

                Section {
                    Button {
                        showingResetConfirmation = true
                    } label: {
                        Label("Reset session", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.white)
                    }
                } header: {
                    Text("Troubleshooting")
                } footer: {
                    Text("Wipes stored cookies and the visitor token. The next playback attempt will run anonymously. Use this if playback or sign-in is stuck.")
                }

                Section {
                    Text("FreeTube is a personal/sideload-only YouTube client. It uses YouTubeKit (cookie-based, no Google API key) plus yt-dlp for downloads. YouTube can change its internal API at any time — please be patient when things break.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("About")
                } footer: {
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
                    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
                    Text("v\(version) (\(build)) — [freetube.io](https://freetube.io)")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset session?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
                Button("Reset", role: .destructive) {
                    Task { await SessionManager.shared.handleExpiredSession() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This signs you out and clears cached cookies.")
            }
        }
    }
}
