import SwiftUI
import FirebaseCore

@main
struct BankaiBuddyApp: App {
    @State private var auth: AuthViewModel
    @State private var library: LibraryStore

    init() {
        FirebaseApp.configure()
        let auth = AuthViewModel()
        let library = LibraryStore()
        #if DEBUG
        if ScreenshotMode.isEnabled {
            auth.enableScreenshotMode()
            Task { await library.seedScreenshotLibrary() }
        }
        #endif
        _auth = State(wrappedValue: auth)
        _library = State(wrappedValue: library)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(auth)
                .environment(library)
                .tint(BrandKit.indigo)
        }
    }
}
