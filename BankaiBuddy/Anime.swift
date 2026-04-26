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

    var posterURL: URL? { imageURL.flatMap(URL.init) }
    var detailURL: URL? { malURL.flatMap(URL.init) }
    var streamableLinks: [StreamingLink] { streamingLinks ?? [] }
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
