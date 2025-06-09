import SwiftUI

/// A highly customizable card view component that can be used throughout the app
/// with consistent styling options and accessibility features.
struct CardView<Content: View>: View {
    // Content
    private let content: Content
    
    // Customization options
    private var cornerRadius: CGFloat
    private var shadowRadius: CGFloat
    private var shadowOpacity: CGFloat
    private var shadowOffset: CGFloat
    private var backgroundColor: Color
    private var borderColor: Color?
    private var borderWidth: CGFloat
    private var padding: EdgeInsets
    
    // For button variation
    private var isButton: Bool
    private var action: (() -> Void)?
    
    // Accessibility
    private var accessibilityLabel: String?
    private var accessibilityHint: String?
    
    // Animation properties
    @State private var isPressed = false
    @State private var isHovered = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.hapticFeedback) private var hapticFeedback
    
    init(
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 5,
        shadowOpacity: CGFloat = 0.1,
        shadowOffset: CGFloat = 2,
        backgroundColor: Color = Color(.secondarySystemBackground),
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        isButton: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.shadowOffset = shadowOffset
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.padding = padding
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.isButton = isButton
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Group {
            if isButton && action != nil {
                buttonVariant
            } else {
                standardVariant
            }
        }
        .accessibilityElement(children: accessibilityLabel == nil ? .contain : .combine)
        .accessibilityLabel(accessibilityLabel ?? "")
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(isButton ? .isButton : [])
    }
    
    private var standardVariant: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(adaptiveBackgroundColor)
                        .shadow(
                            color: adaptiveShadowColor,
                            radius: shadowRadius,
                            x: 0,
                            y: shadowOffset
                        )
                    
                    if let borderColor = borderColor, borderWidth > 0 {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                }
            )
    }
    
    private var buttonVariant: some View {
        Button(action: {
            hapticFeedback.impact(.medium)
            action?()
        }) {
            content
                .padding(padding)
                .frame(maxWidth: .infinity)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(adaptiveBackgroundColor)
                    .shadow(
                        color: adaptiveShadowColor,
                        radius: isPressed ? shadowRadius * 0.5 : shadowRadius,
                        x: 0,
                        y: isPressed ? shadowOffset * 0.5 : shadowOffset
                    )
                
                if let borderColor = borderColor, borderWidth > 0 {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(isPressed ? borderColor.opacity(0.7) : borderColor, lineWidth: borderWidth)
                }
            }
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                if isPressed != pressing {
                    if pressing {
                        hapticFeedback.impact(.soft)
                    }
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPressed = pressing
                    }
                }
            },
            perform: {}
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    // MARK: - Helper Computed Properties
    
    /// Adapts background color based on color scheme
    private var adaptiveBackgroundColor: Color {
        if backgroundColor == Color(.secondarySystemBackground) {
            // Use system background that adapts to light/dark mode
            return Color(.secondarySystemBackground)
        } else {
            // Custom background color - adjust opacity for dark mode if needed
            return colorScheme == .dark ? backgroundColor.opacity(0.92) : backgroundColor
        }
    }
    
    /// Adapts shadow color based on color scheme
    private var adaptiveShadowColor: Color {
        return colorScheme == .dark ?
            Color.white.opacity(shadowOpacity * 0.5) :
            Color.black.opacity(shadowOpacity)
    }
}

// MARK: - Convenience initializers
extension CardView {
    /// Creates a simple card with default styling
    static func simple(@ViewBuilder content: () -> Content) -> CardView<Content> {
        CardView(content: content)
    }
    
    /// Creates a card that functions as a button
    static func button(
        action: @escaping () -> Void,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> CardView<Content> {
        CardView(
            accessibilityLabel: accessibilityLabel,
            accessibilityHint: accessibilityHint,
            isButton: true,
            action: action,
            content: content
        )
    }
    
    /// Creates a highlighted card with a border
    static func highlighted(
        borderColor: Color = .accentColor,
        @ViewBuilder content: () -> Content
    ) -> CardView<Content> {
        CardView(
            shadowRadius: 8,
            shadowOpacity: 0.15,
            borderColor: borderColor,
            borderWidth: 1.5,
            content: content
        )
    }
    
    /// Creates an outlined card with no shadow
    static func outlined(
        borderColor: Color = Color(.systemGray4),
        backgroundColor: Color = Color(.systemBackground),
        @ViewBuilder content: () -> Content
    ) -> CardView<Content> {
        CardView(
            shadowRadius: 0,
            shadowOpacity: 0,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: 1,
            content: content
        )
    }
    
    /// Creates a card with prominent styling for important content
    static func prominent(
        @ViewBuilder content: () -> Content
    ) -> CardView<Content> {
        CardView(
            shadowRadius: 10,
            shadowOpacity: 0.2,
            shadowOffset: 4,
            backgroundColor: Color(.systemBackground),
            content: content
        )
    }
    
    /// Creates a card with minimal styling and compact padding
    static func compact(
        @ViewBuilder content: () -> Content
    ) -> CardView<Content> {
        CardView(
            cornerRadius: 12,
            shadowRadius: 3,
            shadowOpacity: 0.08,
            shadowOffset: 1,
            padding: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
            content: content
        )
    }
}

// MARK: - Preview
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScrollView {
                VStack(spacing: 20) {
                    CardView.simple {
                        Text("Standard Card")
                            .font(.headline)
                    }
                    CardView.highlighted {
                        VStack(alignment: .leading) {
                            Text("Highlighted Card")
                                .font(.headline)
                            Text("With accent border")
                                .font(.subheadline)
                        }
                    }
                    CardView.button(
                        action: {},
                        accessibilityLabel: "Example button card"
                    ) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.accentColor)
                            Text("Tap me!")
                                .font(.headline)
                        }
                    }
                    CardView.outlined {
                        Text("Outlined Card")
                            .font(.headline)
                    }
                    CardView.prominent {
                        VStack {
                            Image(systemName: "star.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                            Text("Prominent Card")
                                .font(.headline)
                        }
                    }
                    CardView.compact {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Compact Card")
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
            }
            .previewDisplayName("Light Mode")
            
            ScrollView {
                VStack(spacing: 20) {
                    CardView.simple {
                        Text("Standard Card")
                            .font(.headline)
                    }
                    CardView.highlighted {
                        VStack(alignment: .leading) {
                            Text("Highlighted Card")
                                .font(.headline)
                            Text("With accent border")
                                .font(.subheadline)
                        }
                    }
                    CardView.button(
                        action: {},
                        accessibilityLabel: "Example button card"
                    ) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.accentColor)
                            Text("Tap me!")
                                .font(.headline)
                        }
                    }
                    CardView.outlined {
                        Text("Outlined Card")
                            .font(.headline)
                    }
                    CardView.prominent {
                        VStack {
                            Image(systemName: "star.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                            Text("Prominent Card")
                                .font(.headline)
                        }
                    }
                    CardView.compact {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("Compact Card")
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
        .environment(\.hapticFeedback, HapticFeedback.shared)
    }
}
