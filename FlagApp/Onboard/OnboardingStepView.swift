import SwiftUI

public struct OnboardingStepView: View {
    private let model: OnboardingView.Model

    public init(
        model: OnboardingView.Model
    ) {
        self.model = model
    }

    public var body: some View {
        VStack {
            self.description
            Spacer()
        }
            .background(
                Image("onboardingBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            )
    }

    private var description: some View {
        HStack {
            VStack(alignment: .leading) {
                Image(self.model.emoji)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                Text(self.model.title)
                    .font(Font.custom("Heebo-Bold", size: 36))
                    .foregroundColor(Color("White1"))
                    .padding(.top, 20)

                Text(self.model.subtitle)
                    .font(Font.custom("Heebo-Medium", size: 27))
                    .foregroundColor(Color("White1"))
                    .padding(.top, 40)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(40)
    }
}
