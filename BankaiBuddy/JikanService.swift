import Foundation

enum JikanService {
    private static let base = URL(string: "https://api.jikan.moe/v4")!

    static func search(_ query: String) async throws -> [Anime] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        var components = URLComponents(url: base.appendingPathComponent("anime"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "q", value: trimmedQuery),
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
        let data = try await request(url)
        let decoded = try JSONDecoder().decode(JikanSingleResponse.self, from: data)
        return decoded.data.asAnime
    }

    private static func fetch(_ url: URL) async throws -> [Anime] {
        let data = try await request(url)
        let decoded = try JSONDecoder().decode(JikanResponse.self, from: data)
        return decoded.data.map { $0.asAnime }
    }

    private static func request(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = 20
        request.setValue("BankaiBuddy/1.0 (iOS)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { return data }

        switch httpResponse.statusCode {
        case 200..<300:
            return data
        case 429:
            throw JikanError.rateLimited
        case 500..<600:
            throw JikanError.serverUnavailable
        default:
            throw JikanError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }
}

enum JikanError: LocalizedError {
    case rateLimited
    case serverUnavailable
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .rateLimited:
            "The anime database is busy. Give it a moment and try again."
        case .serverUnavailable:
            "The anime database is temporarily unavailable."
        case .requestFailed(let statusCode):
            "The anime database returned an unexpected response (\(statusCode))."
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
