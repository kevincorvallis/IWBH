import SwiftUI

struct LogoHeaderView: View {
    @Binding var logoScale: CGFloat
    @Binding var logoOffset: CGFloat
    @Binding var formOpacity: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("IWBH")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .shadow(color: .accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                .scaleEffect(logoScale)
            
            Text("I Wanna Be Held")
                .font(.title3)
                .foregroundColor(.secondary)
                .opacity(formOpacity)
            
            Text("Track your peaceful days together")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .opacity(formOpacity)
        }
        .offset(y: logoOffset)
    }
}
