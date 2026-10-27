import Foundation

enum JikanService {
    private static let base = URL(string: "https://api.jikan.moe/v4")!

    static func search(_ query: String) async throws -> [Anime] {
        var components = URLComponents(url: base.appendingPathComponent("anime"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "q", value: query),
            .init(name: "limit", value: "20"),
            .init(name: "order_by", value: "popularity")
        ]
        return try await fetch(components.url!)
    }

    static func topAiring() async throws -> [Anime] {
        var components = URLComponents(url: base.appendingPathComponent("top/anime"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "filter", value: "airing"),
            .init(name: "limit", value: "15")
        ]
        return try await fetch(components.url!)
    }

    static func fullDetails(for anime: Anime) async throws -> Anime {
        let url = base.appendingPathComponent("anime/\(anime.id)/full")
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        let decoded = try JSONDecoder().decode(JikanSingleResponse.self, from: data)
        return decoded.data.asAnime
    }

    private static func fetch(_ url: URL) async throws -> [Anime] {
        let (data, response) = try await URLSession.shared.data(from: url)
        try validate(response)
        let decoded = try JSONDecoder().decode(JikanResponse.self, from: data)
        return decoded.data.map { $0.asAnime }
    }

    /// Jikan answers rate limits and outages with an error payload, not a
    /// transport error, so a bare `data(from:)` call would surface a cryptic
    /// decode failure. Surface a readable message instead.
    private static func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200..<300:
            return
        case 429:
            throw JikanError.rateLimited
        default:
            throw JikanError.server(status: http.statusCode)
        }
    }
}

enum JikanError: LocalizedError {
    case rateLimited
    case server(status: Int)

    var errorDescription: String? {
        switch self {
        case .rateLimited:
            return "Jikan is rate-limiting requests right now. Try again in a moment."
        case .server(let status):
            return "The anime database returned an error (HTTP \(status)). Try again."
        }
    }
}

private struct JikanResponse: Decodable {
    let data: [JikanAnime]
}

private struct JikanSingleResponse: Decodable {
    let data: JikanAnime
}

private struct JikanAnime: Decodable {
    let mal_id: Int
    let url: String?
    let title: String
    let title_english: String?
    let title_japanese: String?
    let synopsis: String?
    let score: Double?
    let episodes: Int?
    let year: Int?
    let images: Images?
    let genres: [JikanNamedResource]?
    let streaming: [JikanNamedResource]?

    struct Images: Decodable {
        let jpg: Image?
        struct Image: Decodable {
            let image_url: String?
            let large_image_url: String?
        }
    }

    var asAnime: Anime {
        Anime(
            id: mal_id,
            title: title_english ?? title,
            imageURL: images?.jpg?.large_image_url ?? images?.jpg?.image_url,
            synopsis: synopsis,
            score: score,
            episodes: episodes,
            year: year,
            malURL: url,
            titleJapanese: title_japanese,
            genres: genres?.map(\.name),
            streamingLinks: streaming?.map { StreamingLink(name: $0.name, url: $0.url) }
        )
    }
}

private struct JikanNamedResource: Decodable {
    let name: String
    let url: String
}
