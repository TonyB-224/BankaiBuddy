import SwiftUI

struct ProfileView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(LibraryStore.self) private var library
    @State private var showingSignOutConfirm = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.indigo)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(displayName).font(.headline)
                            if let email = emailAddress {
                                Text(email).font(.footnote).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Stats") {
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

                Section {
                    Button(role: .destructive) {
                        showingSignOutConfirm = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
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
        }
    }

    private var emailAddress: String? {
        if case .signedIn(_, let email) = auth.state { return email }
        return nil
    }

    private var displayName: String {
        emailAddress?.components(separatedBy: "@").first?.capitalized ?? "Buddy"
    }
}
