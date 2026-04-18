import Foundation

struct Anime: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let imageURL: String?
    let synopsis: String?
    let score: Double?
    let episodes: Int?
    let year: Int?

    var posterURL: URL? { imageURL.flatMap(URL.init) }
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
