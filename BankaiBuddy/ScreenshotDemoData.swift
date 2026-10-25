#if DEBUG
import Foundation

/// Staged demo data for CI listing screenshots, used ONLY when a screenshot
/// launch includes `-BankaiBuddyScreenshotDemoData` (the CI step adds it
/// when its Jikan probe fails, so a down API can't block the listing set).
/// Titles, poster URLs, scores, episode counts, years, and genres were
/// verified against live MyAnimeList pages on 2026-10-24, and every poster
/// URL returned HTTP 200. Synopses are short original blurbs written for
/// this set, not MAL copy. Order matters: the library seed takes watching
/// from the first 6, favorites from the next 4, watched from the last 4.
/// Never ships: compiled out of Release, and screenshot mode is Debug-only.
enum ScreenshotDemoData {
    static let all: [Anime] = [
        Anime(
            id: 20,
            title: "Naruto",
            imageURL: "https://cdn.myanimelist.net/images/anime/1141/142503.jpg",
            synopsis: "A loud, stubborn ninja with a sealed fox spirit inside him chases his dream of becoming Hokage.",
            score: 8.03,
            episodes: 220,
            year: 2002,
            malURL: "https://myanimelist.net/anime/20",
            titleJapanese: nil,
            genres: ["Action", "Adventure", "Fantasy", "Martial Arts", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 21,
            title: "One Piece",
            imageURL: "https://cdn.myanimelist.net/images/anime/1244/138851.jpg",
            synopsis: "A rubber-bodied pirate captain gathers a crew and sails the Grand Line hunting the legendary treasure.",
            score: 8.72,
            episodes: nil,
            year: 1999,
            malURL: "https://myanimelist.net/anime/21",
            titleJapanese: nil,
            genres: ["Action", "Adventure", "Fantasy", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 40748,
            title: "Jujutsu Kaisen",
            imageURL: "https://cdn.myanimelist.net/images/anime/1171/109222.jpg",
            synopsis: "A high schooler swallows a cursed finger and joins a school that fights curses with cursed energy.",
            score: 8.48,
            episodes: 24,
            year: 2020,
            malURL: "https://myanimelist.net/anime/40748",
            titleJapanese: nil,
            genres: ["Action", "Award Winning", "Supernatural", "School", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 44511,
            title: "Chainsaw Man",
            imageURL: "https://cdn.myanimelist.net/images/anime/1806/126216.jpg",
            synopsis: "A broke devil hunter merges with his chainsaw dog and joins a devil-hunting agency.",
            score: 8.41,
            episodes: 12,
            year: 2022,
            malURL: "https://myanimelist.net/anime/44511",
            titleJapanese: nil,
            genres: ["Action", "Fantasy", "Gore", "Urban Fantasy", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 50265,
            title: "Spy x Family",
            imageURL: "https://cdn.myanimelist.net/images/anime/1441/122795.jpg",
            synopsis: "A spy builds a fake family for a mission, unaware his wife is an assassin and his daughter reads minds.",
            score: 8.40,
            episodes: 12,
            year: 2022,
            malURL: "https://myanimelist.net/anime/50265",
            titleJapanese: nil,
            genres: ["Action", "Award Winning", "Comedy", "Childcare", "Super Power"],
            streamingLinks: nil
        ),
        Anime(
            id: 52991,
            title: "Frieren: Beyond Journey's End",
            imageURL: "https://cdn.myanimelist.net/images/anime/1015/138006.jpg",
            synopsis: "An elf mage outlives her hero party and retraces their journey, learning what their time together meant.",
            score: 9.24,
            episodes: 28,
            year: 2023,
            malURL: "https://myanimelist.net/anime/52991",
            titleJapanese: nil,
            genres: ["Adventure", "Award Winning", "Drama", "Fantasy", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 1,
            title: "Cowboy Bebop",
            imageURL: "https://cdn.myanimelist.net/images/anime/4/19644.jpg",
            synopsis: "Bounty hunters drift through the solar system chasing bounties and outrunning their pasts.",
            score: 8.75,
            episodes: 26,
            year: 1998,
            malURL: "https://myanimelist.net/anime/1",
            titleJapanese: nil,
            genres: ["Action", "Award Winning", "Sci-Fi", "Adult Cast", "Space"],
            streamingLinks: nil
        ),
        Anime(
            id: 5114,
            title: "Fullmetal Alchemist: Brotherhood",
            imageURL: "https://cdn.myanimelist.net/images/anime/1208/94745.jpg",
            synopsis: "Two brothers who broke the law of alchemy search for a stone that can restore their bodies.",
            score: 9.11,
            episodes: 64,
            year: 2009,
            malURL: "https://myanimelist.net/anime/5114",
            titleJapanese: nil,
            genres: ["Action", "Adventure", "Drama", "Fantasy", "Military"],
            streamingLinks: nil
        ),
        Anime(
            id: 11061,
            title: "Hunter x Hunter (2011)",
            imageURL: "https://cdn.myanimelist.net/images/anime/1337/99013.jpg",
            synopsis: "A boy takes the Hunter exam to find his father and meets friends who change the journey.",
            score: 9.03,
            episodes: 148,
            year: 2011,
            malURL: "https://myanimelist.net/anime/11061",
            titleJapanese: nil,
            genres: ["Action", "Adventure", "Fantasy", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 16498,
            title: "Attack on Titan",
            imageURL: "https://cdn.myanimelist.net/images/anime/10/47347.jpg",
            synopsis: "Humanity hides behind walls from man-eating Titans until one boy vows to fight back.",
            score: 8.58,
            episodes: 25,
            year: 2013,
            malURL: "https://myanimelist.net/anime/16498",
            titleJapanese: nil,
            genres: ["Action", "Award Winning", "Drama", "Suspense", "Gore"],
            streamingLinks: nil
        ),
        Anime(
            id: 1535,
            title: "Death Note",
            imageURL: "https://cdn.myanimelist.net/images/anime/1079/138100.jpg",
            synopsis: "A student finds a notebook that kills anyone whose name is written in it, and a detective starts hunting him.",
            score: 8.62,
            episodes: 37,
            year: 2006,
            malURL: "https://myanimelist.net/anime/1535",
            titleJapanese: nil,
            genres: ["Supernatural", "Suspense", "Psychological", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 31964,
            title: "My Hero Academia",
            imageURL: "https://cdn.myanimelist.net/images/anime/10/78745.jpg",
            synopsis: "A powerless boy inherits the world's strongest Quirk and trains to become a hero.",
            score: 7.82,
            episodes: 13,
            year: 2016,
            malURL: "https://myanimelist.net/anime/31964",
            titleJapanese: nil,
            genres: ["Action", "School", "Super Power", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 38000,
            title: "Demon Slayer: Kimetsu no Yaiba",
            imageURL: "https://cdn.myanimelist.net/images/anime/1286/99889.jpg",
            synopsis: "A boy joins the Demon Slayer Corps to avenge his family and cure his demon-turned sister.",
            score: 8.39,
            episodes: 26,
            year: 2019,
            malURL: "https://myanimelist.net/anime/38000",
            titleJapanese: nil,
            genres: ["Action", "Award Winning", "Supernatural", "Historical", "Shounen"],
            streamingLinks: nil
        ),
        Anime(
            id: 37521,
            title: "Vinland Saga",
            imageURL: "https://cdn.myanimelist.net/images/anime/1500/103005.jpg",
            synopsis: "A young Viking seeks revenge on the mercenary leader who killed his father.",
            score: 8.78,
            episodes: 24,
            year: 2019,
            malURL: "https://myanimelist.net/anime/37521",
            titleJapanese: nil,
            genres: ["Action", "Adventure", "Drama", "Gore", "Historical"],
            streamingLinks: nil
        ),
    ]

    static func search(_ query: String) -> [Anime] {
        let q = query.lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { $0.title.lowercased().contains(q) }
    }
}
#endif
