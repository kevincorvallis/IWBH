import UIKit
import SwiftUI

// MARK: - Haptic Feedback Manager
class HapticFeedback {
    static let shared = HapticFeedback()
    
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    func notificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// MARK: - Environment Values
struct HapticFeedbackKey: EnvironmentKey {
    static let defaultValue = HapticFeedback.shared
}

extension EnvironmentValues {
    var hapticFeedback: HapticFeedback {
        get { self[HapticFeedbackKey.self] }
        set { self[HapticFeedbackKey.self] = newValue }
    }
}

// MARK: - View Extensions
extension View {
    func hapticFeedback(_ feedback: HapticFeedback) -> some View {
        environment(\.hapticFeedback, feedback)
    }
}