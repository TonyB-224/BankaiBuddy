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
                    continueWatchingSection
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

    private var continueWatchingSection: some View {
        let items = library.list(.watching)
        return Group {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Continue watching")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(items) { anime in
                                Button { selected = anime } label: {
                                    PosterCard(anime: anime, showsProgress: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
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
            } else if topAiring.isEmpty {
                ContentUnavailableView(
                    "Nothing airing right now",
                    systemImage: "tv.slash",
                    description: Text("Check back soon for fresh picks.")
                )
                .frame(maxWidth: .infinity, minHeight: 200)
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
        #if DEBUG
        if ScreenshotMode.isEnabled && ScreenshotMode.useDemoData {
            topAiring = ScreenshotDemoData.all
            isLoading = false
            return
        }
        #endif
        do {
            topAiring = try await JikanService.topAiring()
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }
}

struct PosterCard: View {
    let anime: Anime
    /// Show the episode counter under the title. Only true for the
    /// user's own watching entries; catalog rows carry no progress.
    var showsProgress: Bool = false

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

            if showsProgress, let label = anime.progressLabel {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if let score = anime.score {
                Label(String(format: "%.1f", score), systemImage: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
    }
}
