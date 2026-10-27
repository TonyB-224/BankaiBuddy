import SwiftUI

struct MainTabView: View {
    @State private var searchText: String
    @State private var selection: String

    init() {
        #if DEBUG
        _searchText = State(initialValue: ScreenshotMode.query)
        let tab = ScreenshotMode.tab
        _selection = State(initialValue: tab == "detail" ? "search" : tab)
        #else
        _searchText = State(initialValue: "")
        _selection = State(initialValue: "home")
        #endif
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house.fill", value: "home") {
                HomeView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: "search", role: .search) {
                SearchView(searchText: $searchText)
            }
            Tab("Library", systemImage: "books.vertical.fill", value: "library") {
                LibraryView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: "profile") {
                ProfileView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .searchable(text: $searchText, prompt: "Search anime")
    }
}
