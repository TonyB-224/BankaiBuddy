import Foundation

struct Anime: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let imageURL: String?
    let synopsis: String?
    let score: Double?
    let episodes: Int?
    let year: Int?
    let malURL: String?
    let titleJapanese: String?
    let genres: [String]?
    let streamingLinks: [StreamingLink]?
    /// Episodes watched, tracked on the user's watching-list entry.
    /// Defaults to 0 so older Firestore docs and API payloads without
    /// this key still decode.
    let progress: Int = 0

    var posterURL: URL? { imageURL.flatMap(URL.init) }
    var detailURL: URL? { malURL.flatMap(URL.init) }
    var streamableLinks: [StreamingLink] { streamingLinks ?? [] }

    /// "Ep 3 of 12", "Ep 3", or nil when nothing has been watched yet.
    var progressLabel: String? {
        guard progress > 0 else { return nil }
        if let episodes { return "Ep \(progress) of \(episodes)" }
        return "Ep \(progress)"
    }

    func withProgress(_ newValue: Int) -> Anime {
        Anime(
            id: id, title: title, imageURL: imageURL, synopsis: synopsis,
            score: score, episodes: episodes, year: year, malURL: malURL,
            titleJapanese: titleJapanese, genres: genres,
            streamingLinks: streamingLinks, progress: newValue
        )
    }
}

struct StreamingLink: Codable, Hashable, Identifiable {
    let name: String
    let url: String

    var id: String { "\(name)-\(url)" }
    var destination: URL? { URL(string: url) }
}

enum ListKind: String, Codable, CaseIterable, Identifiable {
    case watched, watching, favorites

    var id: String { rawValue }
    var title: String {
        switch self {
        case .watched: "Watched"
        case .watching: "Need to Watch"
        case .favorites: "Favorites"
        }
    }
    var symbol: String {
        switch self {
        case .watched: "checkmark.circle.fill"
        case .watching: "bookmark.fill"
        case .favorites: "heart.fill"
        }
    }
}
