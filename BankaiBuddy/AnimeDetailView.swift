import SwiftUI

struct AnimeDetailView: View {
    let anime: Anime
    @Environment(LibraryStore.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var fullAnime: Anime?
    @State private var isLoadingDetails = false

    private var displayAnime: Anime { fullAnime ?? anime }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    poster
                    titleBlock
                    actionButtons
                    streamingSection
                    if let synopsis = displayAnime.synopsis, !synopsis.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Synopsis").font(.headline)
                            Text(synopsis).font(.body)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(displayAnime.title)
            .navigationBarTitleDisplayMode(.inline)
            .task { await loadDetailsIfNeeded() }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var poster: some View {
        AsyncImage(url: displayAnime.posterURL) { image in
            image.resizable().scaledToFit()
        } placeholder: {
            Rectangle().fill(.quaternary)
                .frame(height: 320)
                .overlay(ProgressView())
        }
        .frame(maxHeight: 320)
        .clipShape(.rect(cornerRadius: 18, style: .continuous))
        .padding(.horizontal)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(displayAnime.title).font(.title2.bold())
            if let titleJapanese = displayAnime.titleJapanese, !titleJapanese.isEmpty {
                Text(titleJapanese)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 14) {
                if let year = displayAnime.year {
                    Label(String(year), systemImage: "calendar")
                }
                if let episodes = displayAnime.episodes {
                    Label("\(episodes) eps", systemImage: "tv")
                }
                if let score = displayAnime.score {
                    Label(String(format: "%.1f", score), systemImage: "star.fill")
                        .foregroundStyle(.orange)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let genres = displayAnime.genres, !genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres, id: \.self) { genre in
                            BBChip(title: genre)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            ForEach(ListKind.allCases) { kind in
                let active = library.contains(displayAnime, in: kind)
                Button {
                    Task { await library.toggle(displayAnime, in: kind) }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: kind.symbol)
                            .font(.title3)
                        Text(kind.title)
                            .font(.caption.weight(.medium))
                    }
                    .frame(maxWidth: .infinity, minHeight: 64)
                    .background(
                        active ? BrandKit.indigo : BrandKit.indigo.opacity(0.12),
                        in: .rect(cornerRadius: 14, style: .continuous)
                    )
                    .foregroundStyle(active ? .white : BrandKit.indigo)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var streamingSection: some View {
        let links = displayAnime.streamableLinks
        if !links.isEmpty || isLoadingDetails || displayAnime.detailURL != nil {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Watch links")
                        .font(.headline)
                    Spacer()
                    if isLoadingDetails {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                if links.isEmpty {
                    Text("Checking official stream homes...")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 10) {
                        ForEach(links) { link in
                            if let destination = link.destination {
                                Link(destination: destination) {
                                    HStack {
                                        Label(link.name, systemImage: providerSymbol(for: link.name))
                                            .font(.subheadline.weight(.semibold))
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption.weight(.bold))
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 46)
                                    .padding(.horizontal, 14)
                                    .background(BrandKit.indigo.opacity(0.13), in: .rect(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                if let detailURL = displayAnime.detailURL {
                    Link(destination: detailURL) {
                        Label("Open database page", systemImage: "safari.fill")
                            .font(.footnote.weight(.semibold))
                    }
                }
            }
            .padding(16)
            .background(.regularMaterial, in: .rect(cornerRadius: 18, style: .continuous))
            .padding(.horizontal)
        }
    }

    private func loadDetailsIfNeeded() async {
        guard fullAnime == nil, anime.streamingLinks == nil else { return }
        isLoadingDetails = true
        defer { isLoadingDetails = false }
        fullAnime = try? await JikanService.fullDetails(for: anime)
    }

    private func providerSymbol(for provider: String) -> String {
        let lower = provider.lowercased()
        if lower.contains("netflix") { return "n.square.fill" }
        if lower.contains("youtube") { return "play.rectangle.fill" }
        if lower.contains("crunchyroll") { return "play.tv.fill" }
        return "play.circle.fill"
    }
}
