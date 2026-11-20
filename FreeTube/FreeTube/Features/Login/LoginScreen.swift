import SwiftUI

@available(iOS 17.0, *)
struct LoginScreen: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ContentUnavailableView(
                    "Sign-in unavailable",
                    systemImage: "lock.shield",
                    description: Text("Google sign-in is disabled until FreeTube supports an official OAuth flow. Public content remains available without an account.")
                )
            }
            .navigationTitle("Sign in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
