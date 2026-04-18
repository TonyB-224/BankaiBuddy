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
                VStack(alignment: .leading, spacing: 28) {
                    greeting
                    statsRow
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

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Welcome back")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if case .signedIn(_, let email) = auth.state, let email {
                Text(email.components(separatedBy: "@").first?.capitalized ?? "there")
                    .font(.largeTitle.bold())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            ForEach(ListKind.allCases) { kind in
                VStack(spacing: 6) {
                    Image(systemName: kind.symbol)
                        .font(.title2)
                        .foregroundStyle(.indigo)
                    Text("\(library.list(kind).count)")
                        .font(.title.bold())
                    Text(kind.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.regularMaterial, in: .rect(cornerRadius: 16))
            }
        }
        .padding(.horizontal)
    }

    private var topAiringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Airing")
                    .font(.title2.bold())
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
            .clipShape(.rect(cornerRadius: 12))

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
