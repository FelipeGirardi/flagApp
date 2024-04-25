import Combine
import SwiftUI

let deviceLanguage: String = String(Locale.preferredLanguages.first?.prefix(2) ?? "en")

public struct ChallengesListView: View {
    // MARK: Navigation Settings
    @EnvironmentObject var appNavigationManager: AppNavigationManager
    @ObservedObject var viewModel: ViewModel

    // MARK: Theme
    @EnvironmentObject var theme: Theme

    private let userManager: UserManager
    public init(
        viewModel: ViewModel,
        userManager: UserManager
    ) {
        self.viewModel = viewModel
        self.userManager = userManager
    }

    public var body: some View {
        NavigationView {
            // MARK: uses ScrollView + LazyVStack for iOS 14 and List in older versions
            if #available(iOS 14.0, *) {
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        challengesList()
                            .padding(.horizontal)
                    }
                    .listStyle(PlainListStyle())
                }
                .padding(.top)

                // MARK: UI settings
                .background(
                    Image("challengeList-Background")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
                .navigationBarTitle(deviceLanguage == "pt" ? "Desafios" : "Challenges", displayMode: .large)    // MARK: can't localize nav bar title
            } else {
                List {
                    challengesList()
                }
                .padding(.top)

                // MARK: UI settingsr
                .background(
                    Image("challengeList-Background")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                )
                .navigationBarTitle(deviceLanguage == "pt" ? "Desafios" : "Challenges", displayMode: .large)    // MARK: can't localize nav bar title
            }
        }
        .onAppear {
            self.theme.tabviewHidden = false
        }
        // MARK: Navigation Settings
        .onReceive(self.appNavigationManager.$moveToChallengeList) { moveToChallengeList in
            if moveToChallengeList {
                self.theme.tabviewHidden = false
                self.viewModel.activeViewSetStates.removeAll()
                self.appNavigationManager.moveToChallengeList = false
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())

        // MARK: NÃO DELETAR COMENTÁRIO ABAIXO! (SLIDER)
        // self.slider
    }

    func challengesList() -> some View {
        Group {
            ForEach(self.viewModel.challengeInfos, id: \.self) { challengeInfo in
                ZStack {
                    ChallengeCardView(challengeInfo: challengeInfo)
                        .onTapGesture {
                            self.viewModel.activeViewSetStates.insert(challengeInfo)
                            self.theme.tabviewHidden = true
                        }
                    NavigationLink(
                        destination: IntroChallengeView(
                            challengeInfo: challengeInfo,
                            userManager: self.userManager
                        )
                        .onDisappear(perform: {
                            self.viewModel.activeViewSetStates.remove(challengeInfo)
                        }
                        ),
                        isActive: .constant(
                            self.viewModel.activeViewSetStates.contains(challengeInfo)
                        )
                    ) {
                        EmptyView()
                    }
                    .isDetailLink(false)
                }
            }
            self.comingSoonCell
                .padding(.top, 20)
        }
    }

    private var comingSoonCell: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(NSLocalizedString("More coming soon!", comment: ""))
                    .font(Font.custom("Heebo-Medium", size: 21))
                    .foregroundColor(Color("White1"))

                Spacer()

                Image("comingSoon-info-icon")
                    .frame(width: 10, height: 10)
                    .padding(.leading, 2)
                    .padding(.bottom, 14)
            }
            Text(NSLocalizedString("Coming soon description 1", comment: ""))
                .font(Font.custom("Heebo-Light", size: 14))
                .foregroundColor(Color("White1"))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)

            Text(NSLocalizedString("Have cool insights for us?", comment: ""))
                .font(Font.custom("Heebo-Medium", size: 17))
                .foregroundColor(Color("White1"))

            Text(NSLocalizedString("Coming soon description 2", comment: ""))
                .font(Font.custom("Heebo-Light", size: 14))
                .foregroundColor(Color("White1"))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .padding()
        .background(BlurComingSoonCell())
        .cornerRadius(20)

        .onTapGesture {
            UIApplication.shared.open(URL(string: "https://www.instagram.com/flag_app/")!)
        }
    }

    private var slider: some View {
        EmptyView()
//        SlideOverCard {
//            VStack(alignment: .leading) {
//                HStack {
//                    Spacer()
//
//                    Text("Challenges")
//                        .font(Font.custom("Heebo-Bold", size: 34))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.leading)
//
//                    Spacer()
//                }
//
//                Spacer(minLength: UIScreen.main.bounds.height / 50)
//
//                NavigationView {
//                    List {
//                        ForEach(challengeInfos.indices, id: \.self) { index in
//                            NavigationLink(destination: IntroTNTSmileView()) {
//                                ChallengeView(challengeInfo: challengeInfos[index])
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
}

struct BlurComingSoonCell: UIViewRepresentable {
    let style: UIBlurEffect.Style = .dark

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return blur
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
}
