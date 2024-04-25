import SwiftUI

public struct OnboardingView: View {
    private var controllers: [UIHostingController<OnboardingStepView>]
    private var onboardingSteps: [OnboardingView.Model]
    @State var currentPage = 0
    @Binding var skipOnboarding: Bool

    public init(
        onboardingSteps: [OnboardingView.Model],
        skipOnboarding: Binding<Bool>
    ) {
        self.controllers = onboardingSteps.map {
            UIHostingController(
                rootView: OnboardingStepView(
                    model: $0
                )
            )
        }
        self.onboardingSteps = onboardingSteps
        self._skipOnboarding = skipOnboarding
    }

    public var body: some View {
        NavigationView {
            VStack {
                PageViewController(controllers: self.controllers, currentPage: $currentPage)
                    .edgesIgnoringSafeArea(.all)

                self.nextButton

                PageControl(
                    currentPage: $currentPage,
                    numberOfPages: controllers.count
                )
            }
                .background(
                       Image("onboardingBackground")
                           .resizable()
                           .scaledToFill()
                           .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                           .edgesIgnoringSafeArea(.all)
                   )
            .navigationBarItems(
                trailing: Button(
                    action: {
                        UserDefaults.standard.set(true, forKey: "showedOnboarding")
                        self.skipOnboarding = true
                    },
                    label: {
                        if currentPage == self.controllers.count - 1 {
                            Text("")
                        } else {
                            Text(NSLocalizedString("Skip", comment: "Skip"))
                                .font(Font.custom("Heebo-Semibold", size: 19))
                                .foregroundColor(Color("White1"))
                        }
                    }
                )
            )
        }
    }

    private var nextButton: some View {
        Button(
            action: {
                if self.currentPage == self.controllers.count - 1 {
                    UserDefaults.standard.set(true, forKey: "showedOnboarding")
                    self.skipOnboarding = true
                } else {
                    self.currentPage += 1
                }
            },
            label: {
                ZStack {
                    Color("ButtonColor")
                    Text(self.onboardingSteps[currentPage].buttonLableTitle)
                        .font(Font.custom("Heebo-Semibold", size: 21))
                        .foregroundColor(Color("White1"))
                }
            }
        )
            .frame(height: 50)
            .cornerRadius(20)
            .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onboardingSteps: [.step1, .step2, .step3], skipOnboarding: .constant(false))
    }
}
