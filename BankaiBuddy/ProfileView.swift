import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(LibraryStore.self) private var library
    @State private var showingSignOutConfirm = false
    @State private var showingDeleteConfirm = false
    @State private var accountMessage: String?
    @State private var isDeletingAccount = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        BankaiLogoMark(size: 54, showGlow: false)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(displayName).font(.headline)
                            if let email = emailAddress {
                                Text(email).font(.footnote).foregroundStyle(.secondary)
                            }
                            Text("BankaiBuddy synced profile")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if let accountMessage {
                    Section {
                        Label(accountMessage, systemImage: "info.circle.fill")
                            .font(.footnote)
                    }
                }

                Section("Library Snapshot") {
                    ForEach(ListKind.allCases) { kind in
                        HStack {
                            Label(kind.title, systemImage: kind.symbol)
                            Spacer()
                            Text("\(library.list(kind).count)")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }

                Section("App Store Readiness") {
                    Label("Email/password sign-in with per-user cloud sync", systemImage: "lock.shield.fill")
                    Label("Official streaming links open outside the app", systemImage: "safari.fill")
                    Label("Privacy policy URL still needs to be added in App Store Connect", systemImage: "doc.text.magnifyingglass")
                }

                Section {
                    Button(role: .destructive) {
                        showingSignOutConfirm = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        if isDeletingAccount {
                            ProgressView()
                        } else {
                            Label("Delete Account", systemImage: "trash.fill")
                        }
                    }
                    .disabled(isDeletingAccount || auth.isWorking)
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog(
                "Sign out of BankaiBuddy?",
                isPresented: $showingSignOutConfirm,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) { auth.signOut() }
                Button("Cancel", role: .cancel) { }
            }
            .confirmationDialog(
                "Permanently delete your BankaiBuddy account and saved lists?",
                isPresented: $showingDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This removes your watched, watchlist, and favorites data before deleting the Firebase account.")
            }
        }
    }

    private var emailAddress: String? {
        if case .signedIn(_, let email) = auth.state { return email }
        return nil
    }

    private var displayName: String {
        emailAddress?.components(separatedBy: "@").first?.capitalized ?? "Buddy"
    }

    private func deleteAccount() async {
        isDeletingAccount = true
        accountMessage = nil
        defer { isDeletingAccount = false }

        do {
            try await library.deleteAllUserData()
            let deleted = await auth.deleteAccount()
            if !deleted {
                accountMessage = auth.errorMessage
            }
        } catch {
            accountMessage = "Couldn't delete saved lists. Check your connection and try again."
        }
    }
}
