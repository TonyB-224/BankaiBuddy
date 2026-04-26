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
            BrandKit.nightGradient.ignoresSafeArea()

            Circle()
                .fill(BrandKit.gold.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 55)
                .offset(x: 130, y: -270)

            ScrollView {
                VStack(spacing: 28) {
                    header
                    signOnPanel
                    globalPromise
                    Spacer(minLength: 40)
                }
                .padding(.top, 46)
            }
        }
        .foregroundStyle(.white)
        .animation(.smooth, value: auth.errorMessage)
        .animation(.smooth, value: mode)
    }

    private var header: some View {
        VStack(spacing: 14) {
            BankaiLogoMark(size: 104)
            Text("BankaiBuddy")
                .font(.system(size: 42, weight: .black, design: .rounded))
            Text("Your global anime watch room")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    BBChip(title: "日本", systemImage: "globe.asia.australia.fill")
                    BBChip(title: "Global streams", systemImage: "play.tv.fill")
                    BBChip(title: "Buddy lists", systemImage: "heart.text.square.fill")
                }
            }
            .padding(.top, 2)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }

    private var signOnPanel: some View {
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
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 14, style: .continuous))

                SecureField("Password", text: $password)
                    .textContentType(mode == .signIn ? .password : .newPassword)
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { submit() }
                    .padding(14)
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 14, style: .continuous))
            }

            if let message = auth.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            Button(action: submit) {
                HStack {
                    if auth.isWorking {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: mode == .signIn ? "arrow.right.circle.fill" : "sparkles")
                        Text(mode == .signIn ? "Sign In" : "Create Account")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(BrandKit.gold, in: .rect(cornerRadius: 14, style: .continuous))
                .foregroundStyle(BrandKit.ink)
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
        .background(.ultraThinMaterial.opacity(0.65), in: .rect(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var modePicker: some View {
        Picker("", selection: $mode) {
            Text("Sign In").tag(Mode.signIn)
            Text("Sign Up").tag(Mode.signUp)
        }
        .pickerStyle(.segmented)
        .colorScheme(.dark)
    }

    private var globalPromise: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Built for fans who jump between regions, dubs, subs, queues, and streaming homes.", systemImage: "sparkle.magnifyingglass")
                .font(.footnote.weight(.medium))
            HStack(spacing: 7) {
                Text("Find it")
                Image(systemName: "arrow.right")
                Text("stash it")
                Image(systemName: "arrow.right")
                Text("watch it where it lives")
            }
            .font(.caption)
            .foregroundStyle(.white.opacity(0.7))
            .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.black.opacity(0.18), in: .rect(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 20)
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
