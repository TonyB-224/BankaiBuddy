import SwiftUI

struct MainTabView: View {
    @State private var searchText = ""

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView(searchText: $searchText)
            }
            Tab("Library", systemImage: "books.vertical.fill") {
                LibraryView()
            }
            Tab("Profile", systemImage: "person.crop.circle.fill") {
                ProfileView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .searchable(text: $searchText, prompt: "Search anime")
    }
}
