import SwiftUI
import Kingfisher

@available(iOS 17.0, *)
struct AccountScreen: View {
    @State private var model = AccountViewModel()

    var body: some View {
        NavigationStack {
            List {
                if let info = model.info {
                    Section {
                        HStack(spacing: 12) {
                            KFImage(info.avatarURL)
                                .thumbnail(size: CGSize(width: 64, height: 64)) {
                                    Circle().fill(.gray.opacity(0.2))
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(info.displayName).font(.headline)
                                if let handle = info.handle {
                                    Text(handle).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    Section {
                        Button(role: .destructive) {
                            Task { await model.signOut() }
                        } label: {
                            Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                } else {
                    Section {
                        Label("Google sign-in is unavailable", systemImage: "lock.shield")
                            .foregroundStyle(.secondary)
                    } footer: {
                        Text("The existing sign-in embeds Google authentication in a web view and captures session cookies. This is not official Google OAuth, so account sign-in is disabled until a supported, policy-compliant flow is available. You can still use public content without signing in.")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task { await SessionManager.shared.handleExpiredSession() }
                    } label: {
                        Label("Reset session", systemImage: "arrow.counterclockwise")
                    }
                } footer: {
                    Text("If videos stop loading, tap this to wipe stored cookies and the visitor token. The next playback attempt will run anonymously.")
                }

                Section {
                    NavigationLink {
                        SettingsScreen()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("Account")
            .task { await model.load() }
            .errorToast(Bindable(model).errorState)
        }
    }
}
