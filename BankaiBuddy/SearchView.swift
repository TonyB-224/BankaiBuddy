import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @State private var results: [Anime] = []
    @State private var isLoading = false
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

    private func performSearch(_ query: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            results = try await JikanService.search(query)
        } catch {
            results = []
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
