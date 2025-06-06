import SwiftUI

struct ContentView: View {
    @StateObject private var authModel = AuthenticationModel()
    @StateObject private var connectionModel = PartnerConnectionModel()
    
    var body: some View {
        VStack {
            if authModel.isSignedIn {
                if let _ = connectionModel.userProfile {
                    if connectionModel.pairingStatus == .paired {
                        MainView()
                            .environmentObject(authModel)
                            .environmentObject(connectionModel)
                    } else {
                        PartnerConnectionView(connectionModel: connectionModel, authModel: authModel)
                    }
                } else {
                    ProfileSetupView(connectionModel: connectionModel, authModel: authModel)
                }
            } else {
                LoginView(authModel: authModel)
            }
        }
        .onAppear {
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
