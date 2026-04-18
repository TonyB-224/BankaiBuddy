import SwiftUI

struct AnimeDetailView: View {
    let anime: Anime
    @Environment(LibraryStore.self) private var library
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    poster
                    titleBlock
                    actionButtons
                    if let synopsis = anime.synopsis, !synopsis.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Synopsis").font(.headline)
                            Text(synopsis).font(.body)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(anime.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var poster: some View {
        AsyncImage(url: anime.posterURL) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Rectangle().fill(.quaternary)
                .frame(height: 320)
                .overlay(ProgressView())
        }
        .frame(maxHeight: 320)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(anime.title).font(.title2.bold())
            HStack(spacing: 14) {
                if let year = anime.year {
                    Label(String(year), systemImage: "calendar")
                }
                if let episodes = anime.episodes {
                    Label("\(episodes) eps", systemImage: "tv")
                }
                if let score = anime.score {
                    Label(String(format: "%.1f", score), systemImage: "star.fill")
                        .foregroundStyle(.orange)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            ForEach(ListKind.allCases) { kind in
                let active = library.contains(anime, in: kind)
                Button {
                    Task { await library.toggle(anime, in: kind) }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: kind.symbol)
                            .font(.title3)
                        Text(kind.title)
                            .font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(
                        active ? Color.indigo : Color.indigo.opacity(0.12),
                        in: .rect(cornerRadius: 12)
                    )
                    .foregroundStyle(active ? .white : .indigo)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
