import SwiftUI

enum BrandKit {
    static let ink = Color(red: 0.05, green: 0.06, blue: 0.10)
    static let plum = Color(red: 0.22, green: 0.10, blue: 0.38)
    static let indigo = Color(red: 0.24, green: 0.25, blue: 0.78)
    static let violet = Color(red: 0.50, green: 0.22, blue: 0.86)
    static let gold = Color(red: 1.00, green: 0.68, blue: 0.23)
    static let mint = Color(red: 0.17, green: 0.78, blue: 0.69)

    static var nightGradient: LinearGradient {
        LinearGradient(
            colors: [ink, plum, indigo.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct BankaiLogoMark: View {
    var size: CGFloat = 92
    var showGlow = true

    var body: some View {
        Image("BankaiLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(.rect(cornerRadius: size * 0.22, style: .continuous))
            .shadow(color: showGlow ? BrandKit.gold.opacity(0.35) : .clear, radius: 18, x: 0, y: 10)
            .accessibilityLabel("BankaiBuddy logo")
    }
}

struct BBChip: View {
    let title: String
    var systemImage: String?

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.thinMaterial, in: .capsule)
    }
}
