import Foundation
import FirebaseAuth
import Observation

@Observable
@MainActor
final class AuthViewModel {
    enum State: Equatable {
        case unknown
        case signedOut
        case signedIn(uid: String, email: String?)
    }

    private(set) var state: State = .unknown
    var errorMessage: String?
    var isWorking = false

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }
                if let user {
                    self.state = .signedIn(uid: user.uid, email: user.email)
                } else {
                    self.state = .signedOut
                }
            }
        }
    }

   

    func signIn(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        isWorking = true
        errorMessage = nil
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
        isWorking = false
    }

    func signUp(email: String, password: String) async {
        guard validate(email: email, password: password) else { return }
        isWorking = true
        errorMessage = nil
        do {
            _ = try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
        isWorking = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = "Couldn't sign out. Try again."
        }
    }

    func sendPasswordReset(email: String) async {
        guard !email.isEmpty else {
            errorMessage = "Enter your email first."
            return
        }
        isWorking = true
        errorMessage = nil
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            errorMessage = "Reset email sent. Check your inbox."
        } catch {
            errorMessage = friendlyMessage(for: error)
        }
        isWorking = false
    }

    private func validate(email: String, password: String) -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Email is required."
            return false
        }
        if !email.contains("@") {
            errorMessage = "That doesn't look like a valid email."
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }

    private func friendlyMessage(for error: Error) -> String {
        let code = AuthErrorCode(rawValue: (error as NSError).code)
        switch code {
        case .wrongPassword, .invalidCredential:
            return "Wrong email or password."
        case .userNotFound:
            return "No account found with that email."
        case .emailAlreadyInUse:
            return "An account already exists with that email."
        case .weakPassword:
            return "Password is too weak. Try something longer."
        case .invalidEmail:
            return "That email address isn't valid."
        case .networkError:
            return "Network problem. Check your connection."
        case .tooManyRequests:
            return "Too many attempts. Try again in a moment."
        default:
            return error.localizedDescription
        }
    }
}
