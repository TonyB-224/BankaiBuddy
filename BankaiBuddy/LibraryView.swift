import SwiftUI

struct LibraryView: View {
    @Environment(LibraryStore.self) private var library
    @State private var kind: ListKind = .watching
    @State private var selected: Anime?
    @State private var showingNearby = false
    @State private var sort: SortOption = .title

    enum SortOption: String, CaseIterable {
        case title = "Title A–Z"
        case score = "Top score"
    }

    private var sortedItems: [Anime] {
        let items = library.list(kind)
        switch sort {
        case .title:
            return items.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .score:
            return items.sorted { ($0.score ?? -1) > ($1.score ?? -1) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("List", selection: $kind) {
                    ForEach(ListKind.allCases) { k in
                        Label(k.title, systemImage: k.symbol).tag(k)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                let items = sortedItems
                if items.isEmpty {
                    ContentUnavailableView(
                        emptyTitle,
                        systemImage: kind.symbol,
                        description: Text(emptyMessage)
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(items) { anime in
                                Button { selected = anime } label: {
                                    PosterCard(anime: anime, showsProgress: kind == .watching)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sort) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNearby = true } label: {
                        Label("Share Nearby", systemImage: "person.2.wave.2")
                    }
                }
                if kind == .favorites, !library.list(.favorites).isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: favoritesShareText) {
                            Label("Share Favorites", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingNearby) {
                NearbyShareView(favorites: library.list(.favorites))
            }
            .sheet(item: $selected) { anime in
                AnimeDetailView(anime: anime)
            }
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 140), spacing: 16, alignment: .top)]
    }

    private var favoritesShareText: String {
        let favorites = library.list(.favorites)
        guard !favorites.isEmpty else { return "My BankaiBuddy favorites" }
        return "My BankaiBuddy favorites:\n" + favorites.map { "• \($0.title)" }.joined(separator: "\n")
    }

    private var emptyTitle: String {
        switch kind {
        case .watched: "Nothing watched yet"
        case .watching: "Your watchlist is empty"
        case .favorites: "No favorites yet"
        }
    }

    private var emptyMessage: String {
        switch kind {
        case .watched:
            "Search for anime and tap Watched to log what you have finished."
        case .watching:
            "Search for anime and tap Need to Watch to build your queue."
        case .favorites:
            "Search for anime and tap Favorites to save the series you love."
        }
    }
}
