import SwiftUI

struct HomeView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(LibraryStore.self) private var library

    @State private var topAiring: [Anime] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var selected: Anime?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    statsRow
                    worldFluencySection
                    topAiringSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .refreshable { await load() }
            .task { await load() }
            .sheet(item: $selected) { anime in
                AnimeDetailView(anime: anime)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                BankaiLogoMark(size: 64, showGlow: false)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Welcome back, \(displayName)")
                        .font(.title.bold())
                        .lineLimit(2)
                    Text("Queue the hits, keep the deep cuts, and jump straight to the stream when it is time.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    BBChip(title: "Tokyo pulse", systemImage: "dot.radiowaves.left.and.right")
                    BBChip(title: "Worldwide queue", systemImage: "globe")
                    BBChip(title: "One-tap streams", systemImage: "play.circle.fill")
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandKit.nightGradient, in: .rect(cornerRadius: 28, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "sparkles.tv.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white.opacity(0.10))
                .padding()
        }
        .foregroundStyle(.white)
        .padding(.horizontal)
    }

    private var displayName: String {
        if case .signedIn(_, let email) = auth.state, let email {
            return email.components(separatedBy: "@").first?.capitalized ?? "Buddy"
        }
        return "Buddy"
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            ForEach(ListKind.allCases) { kind in
                VStack(spacing: 6) {
                    Image(systemName: kind.symbol)
                        .font(.title2)
                        .foregroundStyle(BrandKit.indigo)
                    Text("\(library.list(kind).count)")
                        .font(.title.bold())
                    Text(kind.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.regularMaterial, in: .rect(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(.horizontal)
    }

    private var worldFluencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fan fluency")
                .font(.title2.bold())
                .padding(.horizontal)

            VStack(spacing: 10) {
                HomeInsightRow(
                    icon: "character.bubble.fill",
                    title: "Native titles stay visible",
                    message: "Detail pages surface Japanese titles when the source includes them."
                )
                HomeInsightRow(
                    icon: "play.tv.fill",
                    title: "Streaming homes included",
                    message: "Open provider links from the anime detail screen when Jikan has official stream data."
                )
                HomeInsightRow(
                    icon: "books.vertical.fill",
                    title: "Your lists travel with you",
                    message: "Watched, Need to Watch, and Favorites sync per user through Firebase."
                )
            }
            .padding(.horizontal)
        }
    }

    private var topAiringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Airing worldwide")
                        .font(.title2.bold())
                    Text("Fresh from the global conversation")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let loadError {
                ContentUnavailableView("Couldn't load", systemImage: "wifi.exclamationmark", description: Text(loadError))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(topAiring) { anime in
                            Button { selected = anime } label: {
                                PosterCard(anime: anime)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private func load() async {
        isLoading = true
        loadError = nil
        do {
            topAiring = try await JikanService.topAiring()
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }
}

private struct HomeInsightRow: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(BrandKit.gold)
                .frame(width: 32, height: 32)
                .background(BrandKit.gold.opacity(0.13), in: .circle)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.regularMaterial, in: .rect(cornerRadius: 18, style: .continuous))
    }
}

struct PosterCard: View {
    let anime: Anime

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: anime.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    Rectangle().fill(.quaternary)
                        .overlay(ProgressView())
                case .failure:
                    Rectangle().fill(.quaternary)
                        .overlay(Image(systemName: "photo").foregroundStyle(.secondary))
                @unknown default:
                    Rectangle().fill(.quaternary)
                }
            }
            .frame(width: 140, height: 200)
            .clipShape(.rect(cornerRadius: 14, style: .continuous))

            Text(anime.title)
                .font(.caption.weight(.medium))
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)

            if let score = anime.score {
                Label(String(format: "%.1f", score), systemImage: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }
}
