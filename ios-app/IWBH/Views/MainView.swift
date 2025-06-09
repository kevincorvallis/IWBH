import SwiftUI

struct MainView: View {
    @StateObject private var customTrackersModel = CustomTrackersModel()
    @StateObject private var connectionModel = PartnerConnectionModel()
    @StateObject private var authModel = AuthenticationModel()
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
            
            // Chat Tab
            ChatView(authModel: authModel)
                .tabItem {
                    Label("Coach", systemImage: "message.fill")
                }
                .tag(3)

            // Profile Tab
            ProfileView()
                .environmentObject(connectionModel)
                .environmentObject(authModel)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
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
