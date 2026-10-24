import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @State private var results: [Anime] = []
    @State private var isLoading = false
    @State private var searchError: String?
    @State private var selected: Anime?
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty && results.isEmpty {
                    ContentUnavailableView(
                        "Find your next series",
                        systemImage: "magnifyingglass",
                        description: Text("Search by title, character, or studio.")
                    )
                } else if isLoading {
                    ProgressView().controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let searchError {
                    ContentUnavailableView(
                        "Couldn't search",
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
            .task {
                // A prefilled query (CI screenshot mode) never trips
                // onChange, so run the first search on appear.
                if !searchText.isEmpty && results.isEmpty {
                    await performSearch(searchText)
                }
            }
            .sheet(item: $selected) { anime in
                AnimeDetailView(anime: anime)
            }
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                guard !newValue.trimmingCharacters(in: .whitespaces).isEmpty else {
                    results = []
                    searchError = nil
                    isLoading = false
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

    private func performSearch(_ query: String) async {
        isLoading = true
        searchError = nil
        defer { if !Task.isCancelled { isLoading = false } }
        do {
            let found = try await JikanService.search(query)
            guard !Task.isCancelled else { return }
            results = found
            #if DEBUG
            if ScreenshotMode.isEnabled && ScreenshotMode.autoOpenFirstResult {
                selected = found.first
            }
            #endif
        } catch {
            guard !Task.isCancelled else { return }
            results = []
            searchError = error.localizedDescription
        }
    }
}

struct SearchRow: View {
    let anime: Anime

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: anime.posterURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .empty:
                    Rectangle().fill(.quaternary)
                case .failure:
                    Rectangle().fill(.quaternary)
                        .overlay(Image(systemName: "photo").font(.caption).foregroundStyle(.secondary))
                @unknown default:
                    Rectangle().fill(.quaternary)
                }
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
