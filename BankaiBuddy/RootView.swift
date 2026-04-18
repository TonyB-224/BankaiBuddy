import SwiftUI

struct RootView: View {
    @Environment(AuthViewModel.self) private var auth

    var body: some View {
        Group {
            switch auth.state {
            case .unknown:
                ProgressView().controlSize(.large)
            case .signedOut:
                AuthView()
            case .signedIn:
                MainTabView()
            }
        }
        .animation(.smooth, value: auth.state)
    }
}
