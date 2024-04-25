import Foundation

public extension OnboardingView {
    struct Model {
        let emoji: String
        let title: String
        let subtitle: String
        let buttonLableTitle: String
    }
}

public extension OnboardingView.Model {
    static let step1: Self = .init(
        emoji: "thinkingFace",
        title: NSLocalizedString("What the flag?", comment: "What the flag?"),
        subtitle: NSLocalizedString("Onboarding description 1", comment: "Flag is a whole new way to challenge yourself!"),
        buttonLableTitle: NSLocalizedString("HOW DOES THAT WORK?", comment: "HOW DOES THAT WORK?")
    )

    static let step2: Self = .init(
           emoji: "scientist",
           title: "",
           subtitle: NSLocalizedString("Onboarding description 2", comment: "We use algorithms to sense..."),
           buttonLableTitle: NSLocalizedString("AWESOME!", comment: "AWESOME!")
       )

    static let step3: Self = .init(
        emoji: "crown",
        title: NSLocalizedString("Onboarding description 3", comment: "Ready to be the master of challenges?"),
        subtitle: "",
        buttonLableTitle: NSLocalizedString("LET'S DO IT!", comment: "LET'S DO IT!")
    )
}
