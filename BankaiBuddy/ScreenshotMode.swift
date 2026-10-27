#if DEBUG
import Foundation

/// CI-only screenshot mode. It activates only when a Debug simulator build
/// is launched with `-BankaiBuddyScreenshotMode` (the CI screenshot step
/// does this). This file is compiled out of Release builds entirely, and a
/// shipped App Store build cannot receive launch arguments anyway, so the
/// demo state below is unreachable in production.
///
/// Screens: `-BankaiBuddyScreenshotTab home|search|library|profile`, plus
/// `-BankaiBuddyScreenshotQuery <text>` to prefill Search. `detail` is not
/// a tab: it opens the Search tab with the query and auto-opens the first
/// result's detail sheet. `-BankaiBuddyScreenshotDemoData` swaps live Jikan
/// calls for the staged demo set (ScreenshotDemoData) so listing shots can
/// be captured while the API is down; the CI step adds it only when its
/// Jikan probe fails.
enum ScreenshotMode {
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-BankaiBuddyScreenshotMode")
    }

    static var useDemoData: Bool {
        ProcessInfo.processInfo.arguments.contains("-BankaiBuddyScreenshotDemoData")
    }

    static var tab: String {
        value(after: "-BankaiBuddyScreenshotTab") ?? "home"
    }

    static var query: String {
        value(after: "-BankaiBuddyScreenshotQuery") ?? ""
    }

    static var autoOpenFirstResult: Bool { tab == "detail" }

    private static func value(after flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: flag), i + 1 < args.count else { return nil }
        return args[i + 1]
    }
}
#endif
