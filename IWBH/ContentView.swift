import SwiftUI

struct ContentView: View {
    @StateObject private var authModel = AuthenticationModel()
    @StateObject private var connectionModel = PartnerConnectionModel()
    
    var body: some View {
        Group {
            if authModel.isSignedIn {
                if connectionModel.userProfile != nil {
                    if connectionModel.pairingStatus == .paired {
                        MainView()
                            .environmentObject(authModel)
                            .environmentObject(connectionModel)
                    } else {
                        PartnerConnectionView(connectionModel: connectionModel)
                    }
                } else {
                    ProfileSetupView(connectionModel: connectionModel, authModel: authModel)
                }
            } else {
                LoginView(authModel: authModel)
            }
        }
        .onAppear {
            // Create profile automatically after sign in if it doesn't exist
            if authModel.isSignedIn && connectionModel.userProfile == nil {
                connectionModel.createProfile(
                    userID: authModel.userID,
                    name: authModel.userName
                )
            }
        }
    }
} 

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}