import SwiftUI

struct MainView: View {
    @StateObject private var customTrackersModel = CustomTrackersModel()
    @StateObject private var connectionModel = PartnerConnectionModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home/Dashboard Tab
            HomeView()
                .environmentObject(customTrackersModel)
                .environmentObject(connectionModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Trackers Tab
            TrackersView()
                .environmentObject(customTrackersModel)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Trackers")
                }
                .tag(1)
            
            // Activities Tab
            ActivitiesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Activities")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .environmentObject(connectionModel)
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.pink)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}