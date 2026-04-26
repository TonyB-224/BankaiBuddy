import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @State private var results: [Anime] = []
    @State private var isLoading = false
    @State private var searchError: String?
    @State private var selected: Anime?
    @State private var searchTask: Task<Void, Never>?

    private let quickSearches = ["Solo Leveling", "One Piece", "Frieren", "Jujutsu Kaisen", "Demon Slayer"]

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty && results.isEmpty {
                    discoveryState
                } else if isLoading {
                    ProgressView().controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let searchError {
                    ContentUnavailableView(
                        "Search hit a snag",
                        systemImage: "wifi.exclamationmark",
                        description: Text(searchError)
                    )
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(results) { anime in
                        Button { selected = anime } label: {
                            SearchRow(anime: anime)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
            .sheet(item: $selected) { anime in
                AnimeDetailView(anime: anime)
            }
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                searchError = nil
                guard !newValue.trimmingCharacters(in: .whitespaces).isEmpty else {
                    results = []
                    return
                }
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(400))
                    guard !Task.isCancelled else { return }
                    await performSearch(newValue)
                }
            }
        }
    }

    private var discoveryState: some View {
        VStack(spacing: 18) {
            ContentUnavailableView(
                "Find your next series",
                systemImage: "magnifyingglass",
                description: Text("Search by title, character, studio, or try a global fan favorite.")
            )
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 10) {
                Text("Quick jumps")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 10)], spacing: 10) {
                    ForEach(quickSearches, id: \.self) { title in
                        Button {
                            searchText = title
                        } label: {
                            Label(title, systemImage: "sparkle.magnifyingglass")
                                .font(.footnote.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 42)
                        }
                        .buttonStyle(.bordered)
                        .tint(BrandKit.indigo)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func performSearch(_ query: String) async {
        isLoading = true
        searchError = nil
        defer { isLoading = false }
        do {
            results = try await JikanService.search(query)
        } catch {
            results = []
            searchError = error.localizedDescription
        }
    }
}

struct SearchRow: View {
    let anime: Anime

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: anime.posterURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.quaternary)
            }
            .frame(width: 56, height: 80)
            .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(anime.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                HStack(spacing: 8) {
                    if let year = anime.year {
                        Text(String(year))
                    }
                    if let episodes = anime.episodes {
                        Text("\(episodes) eps")
                    }
                    if let score = anime.score {
                        Label(String(format: "%.1f", score), systemImage: "star.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
