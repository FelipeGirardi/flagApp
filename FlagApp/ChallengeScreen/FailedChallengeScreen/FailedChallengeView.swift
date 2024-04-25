import GoogleMobileAds
import SwiftUI

public struct FailedChallengeView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var theme: Theme

    // MARK: Navigation Settings
    @EnvironmentObject var appNavigationManager: AppNavigationManager
//    @State private var isViewActive: Bool = false

    @State var dismissView: Bool = false

    var score: Int = 10
    private let loseSound = Sound(name: "Lose_marimbaLoud", type: "mp3")

    // MARK: Ad Settings
    var interstitial: InterstitialAd

    public init() {
        self.interstitial = InterstitialAd()
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()

                HStack {
                    Spacer()
                    self.topLabel
                    Spacer()
                }

                Spacer(minLength: geometry.size.height * 0.2)

                HStack {
                    Spacer()
                    self.middleLabels(geometry: geometry)
                    Spacer()
                }

                Spacer(minLength: geometry.size.height * 0.25)

                HStack {
                    Spacer()
                    self.mainButton(geometry: geometry)
                    Spacer()
                }

                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .background(
                Color(hex: "#AD0035")
                    .aspectRatio(contentMode: .fill)
                    .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            playSound(sound: self.loseSound)
        }
    }

    private var topLabel: some View {
        Text(NSLocalizedString("Challenge failed :/", comment: "Challenge failed :/"))
            .font(Font.custom("Heebo-Bold", size: 34))
            .foregroundColor(Color("White1"))
            .padding(.top, 50)
    }

    func middleLabels(geometry: GeometryProxy) -> some View {
        VStack(spacing: -25) {
            Image("ChallengeLost")
                .offset(x: -(geometry.size.width * 0.25))

            Text(NSLocalizedString("You’ve run out of Reaction Points!", comment: "You’ve run out of Reaction Points!"))
                .font(Font.custom("Heebo-Bold", size: 26))
                .foregroundColor(Color("White1"))
                .frame(width: geometry.size.width * 0.55)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func mainButton(geometry: GeometryProxy) -> some View {
        Button(
            action: {
                // MARK: Navigation Settings (do not delete yet)
//                self.appNavigationManager.moveToChallengeList = true

                self.dismissView = true
            },
            label: {
                Text(NSLocalizedString("BACK TO MENU", comment: "BACK TO MENU"))
                    .font(Font.custom("Heebo-SemiBold", size: 21))
                    .foregroundColor(Color(hex: "#FF004E"))
                    .background(Color.clear)

                NavigationLink(
                    destination: PreAdView(),
                    isActive: self.$dismissView
                ) {
                    EmptyView()
                }
                .isDetailLink(false)
            }
        )
    }
}
