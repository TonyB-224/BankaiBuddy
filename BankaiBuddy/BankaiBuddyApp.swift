import SwiftUI
import FirebaseCore

@main
struct BankaiBuddyApp: App {
    @State private var auth: AuthViewModel
    @State private var library: LibraryStore

    init() {
        FirebaseApp.configure()
        _auth = State(wrappedValue: AuthViewModel())
        _library = State(wrappedValue: LibraryStore())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(auth)
                .environment(library)
                .tint(.indigo)
        }
    }
}
