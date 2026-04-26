import SwiftUI

struct LibraryView: View {
    @Environment(LibraryStore.self) private var library
    @State private var kind: ListKind = .watching
    @State private var selected: Anime?

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

                let items = library.list(kind)
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
                                    PosterCard(anime: anime)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Library")
            .sheet(item: $selected) { anime in
                AnimeDetailView(anime: anime)
            }
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 140), spacing: 16, alignment: .top)]
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
