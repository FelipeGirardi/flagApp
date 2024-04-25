import Introspect
import SwiftUI

struct MainTabView: View {
    @ObservedObject var tabViewRouter = TabViewRouter()

    private let sessionManager: AuthenticationManager
    private let userManager: UserManager
    private let signInViewModel: SignInViewModel
    private let iapManager: IAPManager
    private var showedOnboarding = false
    @State var skipOnboarding = false

    init(userManager: UserManager, sessionManager: AuthenticationManager, signInViewModel: SignInViewModel, iapManager: IAPManager) {
        self.userManager = userManager
        self.sessionManager = sessionManager
        self.signInViewModel = signInViewModel
        self.iapManager = iapManager
        self.showedOnboarding = UserDefaults.standard.bool(forKey: "showedOnboarding")
    }

    var body: some View {
        ZStack {
            Color("Black1")
                .edgesIgnoringSafeArea(.all)

            if !showedOnboarding && !skipOnboarding {
                OnboardingView(
                    onboardingSteps: [.step1, .step2, .step3],
                    skipOnboarding: $skipOnboarding
                )
            } else {
                TabView(selection: $tabViewRouter.selectedTab) {
                    ChallengesListView(
                        viewModel: .init(),
                        userManager: userManager
                    )
                    .tabItem {
                        Image(tabViewRouter.selectedTab == .challenges ? "FlagIconRed" : "FlagIconGray")
                        Text(NSLocalizedString("Challenges", comment: "Challenges"))
                            .foregroundColor(Color.white)
                            .font(Font.custom("Heebo-Medium", size: 10))
                    }
                    .tag(TabViewRouter.Tab.challenges)

//                    NotificationsScreenView()
//                        .tabItem {
//                            Image(tabViewRouter.selectedTab == .notification ? "ChatIconRed" : "ChatIconGray")
//                            Text("Notifications")
//                        }
//                        .tag(TabViewRouter.Tab.notification)

                    SearchAndRankingView(
                        viewModel: .init(),
                        userManager: self.userManager
                    )
                    .tabItem {
                        Image(tabViewRouter.selectedTab == .ranking ? "TabBar-social-red-icon" : "TabBar-social-gray-icon")
                        Text(NSLocalizedString("Social", comment: "Social"))
                            .foregroundColor(Color.white)
                            .font(Font.custom("Heebo-Medium", size: 10))
                    }
                    .tag(TabViewRouter.Tab.ranking)

                    NavigationView {
                        MainSignInView(signInViewModel: signInViewModel, iapManager: iapManager)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tabItem {
                        VStack {
                            Image(tabViewRouter.selectedTab == .profile ? "ProfileIconRed" : "ProfileIconGray")
                            Text(NSLocalizedString("Profile", comment: "Profile"))
                                .foregroundColor(Color.white)
                                .font(Font.custom("Heebo-Medium", size: 10))
                        }
                    }
                    .tag(TabViewRouter.Tab.profile)
                }
                .tabViewStyle()
            }
        }
    }
}
