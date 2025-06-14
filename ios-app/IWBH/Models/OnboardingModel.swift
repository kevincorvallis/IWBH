import Foundation
import SwiftUI

struct Partner: Identifiable, Codable {
    var id = UUID()
    var name: String = ""
    var loveLanguage: LoveLanguage = .wordsOfAffirmation
    var stressTriggers: [String] = []
    var comfortActivities: [String] = []
    var questionsAnswered: Bool = false

    var loveLanguageString: String {
        get { loveLanguage.rawValue }
        set {
            loveLanguage = LoveLanguage(rawValue: newValue) ?? .wordsOfAffirmation
        }
    }
}

class OnboardingModel: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var partner1 = Partner()
    @Published var partner2 = Partner()
    @Published var relationshipStartDate: Date = Date()
    @Published var currentStep: Int = 0
    @Published var navigationDisabled: Bool = false
    @Published var animationState: String = ""
    @Published var onboardingPages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome", description: "Start your journey", imageName: "star", imageColor: .blue, backgroundColor: .white),
        OnboardingPage(title: "Stay Connected", description: "Stay in touch with your partner", imageName: "heart.fill", imageColor: .red, backgroundColor: .pink),
        OnboardingPage(title: "Celebrate Milestones", description: "Keep track of your special moments", imageName: "calendar", imageColor: .green, backgroundColor: .yellow)
    ]

    let totalSteps = 6

    init() {
        loadData()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        partner1.questionsAnswered = true
        partner2.questionsAnswered = true
        saveData()
    }

    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func validateCurrentStep() -> Bool {
        // Example validation logic
        return currentStep < onboardingPages.count || (partner1.name != "" && partner2.name != "")
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    private func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        defaults.set(relationshipStartDate, forKey: "relationshipStartDate")
        defaults.set(currentStep, forKey: "currentStep")

        if let partner1Data = try? JSONEncoder().encode(partner1) {
            defaults.set(partner1Data, forKey: "partner1")
        }
        if let partner2Data = try? JSONEncoder().encode(partner2) {
            defaults.set(partner2Data, forKey: "partner2")
        }
    }

    private func loadData() {
        let defaults = UserDefaults.standard
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        relationshipStartDate = defaults.object(forKey: "relationshipStartDate") as? Date ?? Date()
        currentStep = defaults.integer(forKey: "currentStep")

        if let partner1Data = defaults.data(forKey: "partner1"),
           let decodedPartner1 = try? JSONDecoder().decode(Partner.self, from: partner1Data) {
            partner1 = decodedPartner1
        }

        if let partner2Data = defaults.data(forKey: "partner2"),
           let decodedPartner2 = try? JSONDecoder().decode(Partner.self, from: partner2Data) {
            partner2 = decodedPartner2
        }
    }
}
