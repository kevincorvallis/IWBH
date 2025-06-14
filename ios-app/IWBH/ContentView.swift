import SwiftUI

struct ContentView: View {
    @StateObject private var authModel = AuthenticationModel()
    @StateObject private var connectionModel = PartnerConnectionModel()
    
    @Namespace private var viewTransition
    @State private var showingFirstTimeSetup = false
    
    var body: some View {
        ZStack {
            if showingFirstTimeSetup {
                OnboardingView(model: OnboardingModel()) 
                    .transition(AnyTransition.asymmetric(
                        insertion: AnyTransition.move(edge: .bottom).combined(with: AnyTransition.opacity),
                        removal: AnyTransition.move(edge: .bottom).combined(with: AnyTransition.opacity)
                    ))
                    .zIndex(2)
            }
            else if authModel.isSignedIn {
                if let _ = connectionModel.userProfile {
                    if connectionModel.pairingStatus == .paired {
                        MainView()
                            .environmentObject(authModel)
                            .environmentObject(connectionModel)
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.move(edge: .trailing).combined(with: AnyTransition.opacity),
                                removal: AnyTransition.move(edge: .leading).combined(with: AnyTransition.opacity)
                            ))
                            .zIndex(1)
                            .matchedGeometryEffect(id: "mainContainer", in: viewTransition)
                    } else {
                        PartnerConnectionView(connectionModel: connectionModel, authModel: authModel)
                            .transition(AnyTransition.asymmetric(
                                insertion: AnyTransition.scale(scale: 0.9).combined(with: AnyTransition.opacity),
                                removal: AnyTransition.scale(scale: 1.1).combined(with: AnyTransition.opacity)
                            ))
                            .zIndex(0.5)
                            .matchedGeometryEffect(id: "connectionContainer", in: viewTransition)
                    }
                } else {
                    ProfileSetupView(connectionModel: connectionModel, authModel: authModel)
                        .transition(AnyTransition.asymmetric(
                            insertion: AnyTransition.move(edge: .bottom).combined(with: AnyTransition.opacity),
                            removal: AnyTransition.move(edge: .top).combined(with: AnyTransition.opacity)
                        ))
                        .zIndex(0.5)
                        .matchedGeometryEffect(id: "setupContainer", in: viewTransition)
                }
            } else {
                LoginView(authModel: authModel)
                    .transition(AnyTransition.asymmetric(
                        insertion: AnyTransition.move(edge: .bottom).combined(with: AnyTransition.opacity),
                        removal: AnyTransition.scale(scale: 0.9).combined(with: AnyTransition.opacity)
                    ))
                    .zIndex(0)
                    .matchedGeometryEffect(id: "loginContainer", in: viewTransition)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: authModel.isSignedIn)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: connectionModel.userProfile != nil)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: connectionModel.pairingStatus)
        .onAppear {
            if authModel.isSignedIn && connectionModel.userProfile == nil {
                withAnimation(.easeInOut(duration: 0.3)) {
                    connectionModel.createProfile(
                        userID: authModel.userID,
                        name: authModel.userName
                    )
                }
            }
            if authModel.isSignedIn && !authModel.hasCompletedFirstTimeSetup && !authModel.isGuest {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showingFirstTimeSetup = true
                    }
                }
            }
        }
        .onChange(of: authModel.isSignedIn) { _, isSignedIn in
            if isSignedIn && !authModel.hasCompletedFirstTimeSetup && !authModel.isGuest {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showingFirstTimeSetup = true
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
