import SwiftUI

struct OnboardingView: View {
    @ObservedObject var model: OnboardingModel
    @State private var pageOffset: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimatingIntro = false
    @State private var isButtonPulsing = false

    private let hapticFeedback = UINotificationFeedbackGenerator()

    private var currentPage: Int {
        min(model.currentStep, model.onboardingPages.count - 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if currentPage < model.onboardingPages.count {
                    model.onboardingPages[currentPage].backgroundColor
                        .ignoresSafeArea()
                        .transition(
                            .asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .trailing)),
                                removal: .opacity.combined(with: .move(edge: .leading))
                            )
                        )
                }

                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Button(action: {
                                hapticFeedback.notificationOccurred(.success)
                                model.previousStep()
                            }) {
                                HStack(spacing: 5) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Back")
                                        .font(.subheadline.weight(.medium))
                                }
                                .foregroundColor(model.currentStep > 0 ? .primary : .primary.opacity(0.3))
                                .padding(8)
                            }
                            .disabled(model.currentStep == 0)
                            .accessibilityHint("Go back to previous screen")

                            Spacer()

                            if model.currentStep < model.totalSteps - 1 {
                                Button(action: {
                                    hapticFeedback.notificationOccurred(.success)
                                    model.completeOnboarding()
                                }) {
                                    Text("Skip")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                }
                                .accessibilityHint("Skip onboarding and go to the app")
                            }
                        }
                        .padding(.horizontal)

                        HStack(spacing: 8) {
                            ForEach(0..<model.onboardingPages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.accentColor : Color.secondary.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: currentPage)
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 16)
                    }

                    ZStack {
                        if currentPage < model.onboardingPages.count {
                            onboardingPageView(page: model.onboardingPages[currentPage], geometry: geometry)
                                .transition(.asymmetric(insertion: .opacity.combined(with: .slide), removal: .opacity))
                                .id("Page-\(currentPage)")
                        } else {
                            personalizedFormPage(geometry: geometry)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                                .id("Form-\(model.currentStep)")
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                dragOffset = gesture.translation.width
                            }
                            .onEnded { gesture in
                                let threshold = geometry.size.width * 0.25
                                if gesture.translation.width > threshold {
                                    model.previousStep()
                                    hapticFeedback.notificationOccurred(.success)
                                } else if gesture.translation.width < -threshold {
                                    if model.validateCurrentStep() {
                                        model.nextStep()
                                        hapticFeedback.notificationOccurred(.success)
                                    } else {
                                        hapticFeedback.notificationOccurred(.error)
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    .offset(x: dragOffset)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dragOffset)
                    .modifier(ShakeEffect(shake: model.animationState == "shake"))

                    ZStack {
                        Button(action: {
                            hapticFeedback.notificationOccurred(.success)
                            if model.validateCurrentStep() {
                                model.nextStep()
                            } else {
                                hapticFeedback.notificationOccurred(.error)
                            }
                        }) {
                            HStack {
                                Text(model.currentStep == model.totalSteps - 1 ? "Get Started" : "Continue")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                if model.currentStep < model.totalSteps - 1 {
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                            .scaleEffect(isButtonPulsing ? 1.03 : 1.0)
                            .animation(isButtonPulsing ? Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: isButtonPulsing)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .accessibilityHint(model.currentStep == model.totalSteps - 1 ? "Complete onboarding and start using the app" : "Continue to the next step")
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                    .background(
                        Rectangle()
                            .fill(Material.regularMaterial)
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                hapticFeedback.prepare()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isButtonPulsing = model.currentStep == 0
                    }
                }
                withAnimation(.easeIn(duration: 0.7)) {
                    isAnimatingIntro = true
                }
            }
            .onChange(of: model.currentStep) { _, newValue in
                withAnimation {
                    isButtonPulsing = newValue == 0
                }
            }
        }
    }

    private func onboardingPageView(page: OnboardingPage, geometry: GeometryProxy) -> some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundColor(page.imageColor)
                .frame(width: 130, height: 130)
                .background(
                    Circle()
                        .fill(page.imageColor.opacity(0.15))
                        .frame(width: 140, height: 140)
                )
                .background(
                    Circle()
                        .stroke(page.imageColor.opacity(0.3), lineWidth: 2)
                        .frame(width: 160, height: 160)
                )
                .scaleEffect(isAnimatingIntro ? 1.0 : 0.5)
                .opacity(isAnimatingIntro ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isAnimatingIntro)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .id(page.title)

                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .id(page.description)
            }
            .opacity(isAnimatingIntro ? 1.0 : 0.0)
            .offset(y: isAnimatingIntro ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: isAnimatingIntro)

            Spacer()
            Spacer()
        }
        .padding(.horizontal)
        .onChange(of: page.title) {
            isAnimatingIntro = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeIn(duration: 0.5)) {
                    isAnimatingIntro = true
                }
            }
        }
    }

    private func personalizedFormPage(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            switch model.currentStep {
            case model.onboardingPages.count:
                partnerNamesView()
            case model.onboardingPages.count + 1:
                relationshipDateView()
            default:
                Text("Completing Setup...")
                    .font(.title2)
                    .padding()
            }
        }
        .padding()
        .background(CardView.simple { Color.clear })
    }

    private func partnerNamesView() -> some View {
        VStack(spacing: 20) {
            Text("Tell us about you")
                .font(.title.weight(.bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text("We'll personalize your experience based on your names")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your name")
                    .font(.headline)
                    .foregroundColor(.primary)
                TextField("", text: $model.partner1.name)
                    .placeholder(when: model.partner1.name.isEmpty) {
                        Text("Enter your name").foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(model.partner1.name.isEmpty ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1.5))
            }
            .padding(.bottom, 5)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your partner's name")
                    .font(.headline)
                    .foregroundColor(.primary)
                TextField("", text: $model.partner2.name)
                    .placeholder(when: model.partner2.name.isEmpty) {
                        Text("Enter your partner's name").foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(model.partner2.name.isEmpty ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1.5))
            }

            if model.partner1.name.isEmpty || model.partner2.name.isEmpty {
                Text("Both names are required to continue")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
    }

    private func relationshipDateView() -> some View {
        VStack(spacing: 20) {
            Text("When did your relationship begin?")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text("This helps us track important milestones together.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            DatePicker("Relationship start date", selection: $model.relationshipStartDate, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                .padding(.horizontal, 5)

            Text("Your anniversary: \(formattedAnniversaryDate())")
                .font(.headline)
                .foregroundColor(.accentColor)
                .padding(.top, 10)
        }
    }

    private func formattedAnniversaryDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: model.relationshipStartDate)
    }
}

struct ShakeEffect: GeometryEffect {
    var shake: Bool
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat = 0

    func effectValue(size: CGSize) -> ProjectionTransform {
        guard shake else { return ProjectionTransform(.identity) }
        let percentage = sin(animatableData * .pi * CGFloat(shakesPerUnit))
        let transform = CGAffineTransform(translationX: percentage * amount, y: 0)
        return ProjectionTransform(transform)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(model: OnboardingModel())
    }
}
