import SwiftUI

public struct EndChallengeScreen: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var theme: Theme

    // MARK: Navigation Settings
    @EnvironmentObject var appNavigationManager: AppNavigationManager
    @State private var dismissView: Bool = false
    @State private var didPassLevel: Bool = false

    @State var streakCoins: Int = 0
    let streakString1: String = NSLocalizedString("%d day streak!", comment: "%d day streak!")
    let streakString2: String = NSLocalizedString("+ %d peak tokens!", comment: "+ %d peak tokens!")

    let scoreObtained: Int
    private let userManager: UserManager
    private let winSound = Sound(name: "Win_marimbaLoud", type: "mp3")

    public init(scoreObtained: Int, userManager: UserManager) {
        self.scoreObtained = scoreObtained
        self.userManager = userManager
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
                    self.middleLabels
                    Spacer()
                }

                Spacer(minLength: geometry.size.height * 0.125)

                HStack {
                    Spacer()
                    self.shareButton
                    Spacer()
                }

                Spacer(minLength: geometry.size.height * 0.125)

                HStack {
                    Spacer()
                    self.continueButton(geometry: geometry)
                    Spacer()
                }

                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .background(
                Color(hex: "#049BF5")
                    .aspectRatio(contentMode: .fill)
                    .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
        }.onAppear {
            playSound(sound: self.winSound)
        }
    }

    private var topLabel: some View {
        Text(NSLocalizedString("Challenge completed!", comment: "Challenge completed!"))
            .font(Font.custom("Heebo-Bold", size: 34))
            .foregroundColor(Color("White1"))
            .padding(.top, 50)
    }

    private var middleLabels: some View {
        VStack(spacing: 10) {
            VStack(spacing: -10) {
                Text(NSLocalizedString("You got", comment: "You got"))
                    .font(Font.custom("Heebo-Light", size: 20))
                    .foregroundColor(Color("White1"))

                Text("\(self.scoreObtained)")
                    .font(Font.custom("Heebo-Bold", size: 82))
                    .foregroundColor(Color("White1"))

                Text(NSLocalizedString("Reaction Points", comment: "Reaction Points"))
                    .font(Font.custom("Heebo-Bold", size: 26))
                    .foregroundColor(Color("White1"))
            }

            // MARK: Peak tokens win and streak settings
//            VStack(spacing: 10) {
//                Text(NSLocalizedString("+ 2 peak tokens!", comment: "+ 2 peak tokens!"))
//                    .font(Font.custom("Heebo-Light", size: 20))
//                    .foregroundColor(Color("White1"))
//
//                if streakCoins != 0 {
//                    VStack(spacing: 2) {
//                        Text(String.localizedStringWithFormat(streakString1, self.streakCoins))
//                            .font(Font.custom("Heebo-Light", size: 20))
//                            .foregroundColor(Color("White1"))
//                            .multilineTextAlignment(.center)
//
//                        Text(String.localizedStringWithFormat(streakString2, self.streakCoins))
//                            .font(Font.custom("Heebo-Light", size: 20))
//                            .foregroundColor(Color("White1"))
//                            .multilineTextAlignment(.center)
//                    }
//                }
//            }
        }
    }

    func continueButton(geometry: GeometryProxy) -> some View {
        Button(
            action: {
                // MARK: Navigation Settings (do not delete yet)
                //self.appNavigationManager.moveToChallengeList = true
                self.streakCoins = 0
                self.dismissView = true
            },
            label: {
                Text(NSLocalizedString("CONTINUE", comment: "CONTINUE"))
                    .font(Font.custom("Heebo-SemiBold", size: 21))
                    .foregroundColor(Color("White1"))
                    .frame(width: geometry.size.width - 36, height: geometry.size.height * 0.075)
                    .background(Color("Red1"))
                    .cornerRadius(50)

                NavigationLink(
                    destination: LevelProgressScreen(scoreObtained: scoreObtained, userManager: userManager),
                    isActive: self.$dismissView
                ) {
                    EmptyView()
                }
                .isDetailLink(false)
            }
        )
    }

    private var shareButton: some View {
        Button(
            action: { shareActionSheet() },
            label: {
                HStack(alignment: .center) {
                    Image("shareButton")
                        .resizable()
                        .frame(width: 20, height: 25)
                        .padding(.trailing, 10)
                    Text("SHARE RESULT")
                        .font(Font.custom("Heebo-Medium", size: 21))
                        .foregroundColor(Color("White1"))
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("Red1"), lineWidth: 1)
                )
            }
        )
    }

    func shareActionSheet() {
        let deviceLanguage: String = String(Locale.preferredLanguages.first?.prefix(2) ?? "en")
        var image = UIImage(named: "share_image_en") as Any

        guard let deeplink = URL(string: "https://flagapp.page.link/flag1") else {
            return
        }

        if deviceLanguage == "pt" {
            image = UIImage(named: "share_image_pt") as Any
        }
        
        let activityController = UIActivityViewController(
            activityItems: [
                deeplink,
                NSLocalizedString("ShareResultMessage", comment: "Share Result Message"),
                image
            ],
            applicationActivities: nil
        )
        activityController.excludedActivityTypes = [
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToVimeo
        ]
        UIApplication.shared.windows.first?.rootViewController?.present(activityController, animated: true, completion: nil)
    }

    func checkDailyRewardStreak() {
        if let date = UserDefaults.standard.object(forKey: "currentDate") as? Date {
            if let diff = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour {
                if diff < 24 {
                    // No reward (same streak) - 24h not passed yet, maintain current data
                    print("\n\n ****************")
                    print("\n NO REWARDS - A day has not passed!")
                    print("\n currentDate data: \(date) Actual Date today, updated: \(Date()) diff: \(diff) ")
                    print("\n\n ****************")
                    self.streakCoins = 0
                } else if diff >= 24 && diff < 48 {
                    // Got reward (increase day streak +1) - passed 1 day
                    print("\n\n ****************")
                    print("\n YOU GOT REWARDED! - A day has passed!")
                    print("\n currentDate data: \(date) Actual Date today, updated: \(Date()) diff: \(diff) ")
                    print("\n\n ****************")

                    // Update Current Date Data
                    print("\n User reward date will be updated...")
                    print("\n\n ****************")
                    UserDefaults.standard.set(Date(), forKey: "currentDate")

                    // Streak reward
                    if let streak = UserDefaults.standard.object(forKey: "currentStreak") as? Int {
                        self.streakCoins = streak + 1
                        UserDefaults.standard.set(streak + 1, forKey: "currentStreak")
                    }
                } else if diff >= 48 {
                    // No reward (reward streak reset to 1) - lost 1 full day of game, need to update date
                    print("\n\n ****************")
                    print("\n NO REWARDS - More than 2 days passed!")
                    print("\n currentDate data: \(date) Actual Date today, updated: \(Date()) diff: \(diff) ")
                    print("\n\n ****************")

                    // Update Current Date Data
                    print("\n User reward date will be updated...")
                    print("\n\n ****************")
                    UserDefaults.standard.set(Date(), forKey: "currentDate")

                    // Set current streak to 1
                    UserDefaults.standard.set(1, forKey: "currentStreak")
                    self.streakCoins = 0
                }
            }
        } else {
            // Got Reward (start streak with 1) - current Date data doesn't exists yet (nil)
            print("\n\n ****************")
            print("\n YOU GOT REWARDED! - First time using app, Date dont exist yet")
            print("\n\n ****************")

            // Update Current Date Data
            print("\n User reward date will be updated...")
            print("\n\n ****************")
            UserDefaults.standard.set(Date(), forKey: "currentDate")
            
            // Set current streak to 1
            UserDefaults.standard.set(1, forKey: "currentStreak")
        }
    }
}
