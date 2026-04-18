import SwiftUI

struct AuthView: View {
    @Environment(AuthViewModel.self) private var auth

    enum Mode { case signIn, signUp }
    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focus: Field?

    enum Field { case email, password }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo.opacity(0.8), .purple.opacity(0.6), .black],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    VStack(spacing: 16) {
                        modePicker

                        VStack(spacing: 12) {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focus, equals: .email)
                                .submitLabel(.next)
                                .onSubmit { focus = .password }
                                .padding(14)
                                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))

                            SecureField("Password", text: $password)
                                .textContentType(mode == .signIn ? .password : .newPassword)
                                .focused($focus, equals: .password)
                                .submitLabel(.go)
                                .onSubmit { submit() }
                                .padding(14)
                                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
                        }

                        if let message = auth.errorMessage {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                        }

                        Button(action: submit) {
                            ZStack {
                                if auth.isWorking {
                                    ProgressView().tint(.white)
                                } else {
                                    Text(mode == .signIn ? "Sign In" : "Create Account")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(.white.opacity(0.95), in: .rect(cornerRadius: 12))
                            .foregroundStyle(.indigo)
                        }
                        .disabled(auth.isWorking)

                        if mode == .signIn {
                            Button("Forgot password?") {
                                Task { await auth.sendPasswordReset(email: email) }
                            }
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial.opacity(0.5), in: .rect(cornerRadius: 20))
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 60)
            }
        }
        .foregroundStyle(.white)
        .animation(.smooth, value: auth.errorMessage)
        .animation(.smooth, value: mode)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "sparkles.tv")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.white)
            Text("BankaiBuddy")
                .font(.largeTitle.bold())
            Text("Track every series worth watching")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var modePicker: some View {
        Picker("", selection: $mode) {
            Text("Sign In").tag(Mode.signIn)
            Text("Sign Up").tag(Mode.signUp)
        }
        .pickerStyle(.segmented)
        .colorScheme(.dark)
    }

    private func submit() {
        focus = nil
        Task {
            switch mode {
            case .signIn: await auth.signIn(email: email, password: password)
            case .signUp: await auth.signUp(email: email, password: password)
            }
        }
    }
}
