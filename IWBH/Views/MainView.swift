import SwiftUI

struct MainView: View {
    @StateObject private var customTrackersModel = CustomTrackersModel()
    @StateObject private var connectionModel = PartnerConnectionModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environmentObject(customTrackersModel)
                .environmentObject(connectionModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Trackers Tab
            TrackersView()
                .environmentObject(customTrackersModel)
                .tabItem {
                    Label("Trackers", systemImage: "chart.bar.fill")
                }
                .tag(1)

            // Activities Tab
            ActivitiesView()
                .tabItem {
                    Label("Activities", systemImage: "heart.fill")
                }
                .tag(2)

            // Profile Tab
            ProfileView()
                .environmentObject(connectionModel)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(3)
        }
        .accentColor(Color.pink)
        .preferredColorScheme(.none) // Respect system-wide dark/light mode
        .onAppear {
            // Optional: UI appearance tweaks
            UITabBar.appearance().backgroundColor = UIColor.systemBackground
            UITabBar.appearance().barTintColor = UIColor.systemBackground
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark) // Preview dark mode
    }
}
