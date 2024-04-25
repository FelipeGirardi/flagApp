//
//  RewardsView.swift
//  FlagApp
//
//  Created by Luiz Antonio Bolsoni Riboli on 24/11/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import SwiftUI

public struct RewardsView: View {
    @State var dismissView: Bool = false
    private let userManager: UserManager

    // MARK: Peak tokens streak settings
    @State var streakCoins: Int = 0
    let streakString1: String = NSLocalizedString("%d day streak!", comment: "%d day streak!")
    let streakString2: String = NSLocalizedString("+ %d peak tokens!", comment: "+ %d peak tokens!")

    // Normal animation
    @State private var showTitle: Bool = false
    @State private var showRewardView: Bool = false
    @State private var showChallengeCompleteMessage: Bool = false
    @State private var challengeCompleteOffset: CGFloat = 0.0
    @State private var showInfoMessage: Bool = false
    @State private var showCoolButton: Bool = false

    // Streak animation
    @State private var showStreakAnimation: Bool = false
    @State private var hideStreakAnimation: Bool = false
    @State private var showDayStreakMessage: Bool = false
    @State private var dayStreakOffset: CGFloat = 0.0

    public init(userManager: UserManager) {
        self.userManager = userManager
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Text(NSLocalizedString("Reward time!", comment: "Reward time!"))
                    .font(Font.custom("Heebo-Bold", size: 34))
                    .foregroundColor(Color("White1"))
                    .padding(.top, 50)
                    .opacity(self.showTitle ? 1.0 : 0.0)

                Spacer()

                VStack(spacing: -10) {
                    VStack(spacing: 0) {
                        streakDayMessage
                            .offset(x: 0.0, y: dayStreakOffset)
                            .opacity(self.showDayStreakMessage ? 1.0 : 0.0)

                        challengeCompleteMessage
                            .offset(x: 0.0, y: challengeCompleteOffset)
                            .opacity(self.showChallengeCompleteMessage ? 1.0 : 0.0)
                    }
                    rewardView
                        .opacity(self.showRewardView ? 1.0 : 0.0)
                }

                Spacer()

                infoMessage(geometry: geometry)
                    .opacity(self.showInfoMessage ? 1.0 : 0.0)

                Spacer()

                continueButton(geometry: geometry)
                    .opacity(self.showCoolButton ? 1.0 : 0.0)
            }
            .frame(width: geometry.size.width)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                checkDailyRewardStreak()
                self.userManager.updateCash(withValue: 2 + self.streakCoins)
                executeAnimationFlow()
            }
        }
    }

    private var rewardView: some View {
        VStack(spacing: 4) {
            Text("Peak Tokens")
                .font(Font.custom("Heebo-Regular", size: 18))
                .foregroundColor(Color("Blue1"))

            HStack {
                Image("peakTokenStacked")
                    .resizable()
                    .frame(width: 78, height: 61)

                ZStack {
                    Text("+ 2")
                        .font(Font.custom("Heebo-Medium", size: 42))
                        .foregroundColor(Color("Blue1"))
                        .opacity(self.hideStreakAnimation ? 0.0 : 1.0)

                    Text(String.localizedStringWithFormat("+ \(2 + streakCoins)", self.streakCoins))
                        .font(Font.custom("Heebo-Medium", size: 42))
                        .foregroundColor(Color("Blue1"))
                        .opacity(self.showStreakAnimation ? 1.0 : 0.0)
                }
            }
        }
        .frame(width: 250, height: 114, alignment: .center)
        .background(Color(hex: "005468"))
        .cornerRadius(15)
    }

    private var challengeCompleteMessage: some View {
        ZStack {
            Image("challengeComplete-background")
                .resizable()
                .frame(width: 205, height: 15)
                .padding(.top, 10)

            Text(NSLocalizedString("Challenge completed!", comment: "Challenge completed!"))
                .font(Font.custom("Heebo-Medium", size: 17))
                .foregroundColor(Color("White1"))
        }
    }

    private var streakDayMessage: some View {
        ZStack {
            Image("streakMessage-background")
                .resizable()
                .frame(width: 160, height: 15)
                .padding(.top, 10)

            Text(String.localizedStringWithFormat(streakString1, self.streakCoins))
                .font(Font.custom("Heebo-Medium", size: 17))
                .foregroundColor(Color("White1"))
        }
    }

    func infoMessage(geometry: GeometryProxy) -> some View {
        Text(NSLocalizedString("Use your tokens", comment: "Use your tokens"))
            .frame(width: geometry.size.width * 0.55)
            .font(Font.custom("Heebo-Regular", size: 16))
            .foregroundColor(Color("Blue1"))
            .minimumScaleFactor(0.7)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }

    func executeAnimationFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // show title
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showTitle = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { // show reward view
            withAnimation(.easeInOut(duration: 0.7)) {
                self.showRewardView = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) { // show challenge complete
            withAnimation(.easeInOut(duration: 0.6)) {
                self.showChallengeCompleteMessage = true
                self.showInfoMessage = true
            }
            withAnimation(.easeInOut(duration: 0.7)) {
                self.challengeCompleteOffset = -22.0
            }
        }

        if streakCoins != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { // show streak views (if available)
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.showStreakAnimation = true
                    self.hideStreakAnimation = true
                    self.showDayStreakMessage = true
                }

                withAnimation(.easeInOut(duration: 0.7)) {
                    self.dayStreakOffset = -30.0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) { // show cool button
            withAnimation(.easeInOut(duration: 0.8)) {
                self.showCoolButton = true
            }
        }
    }

    func continueButton(geometry: GeometryProxy) -> some View {
        Button(
            action: {
                // MARK: Navigation Settings (do not delete yet)
//                self.appNavigationManager.moveToChallengeList = true
                self.dismissView = true
            },
            label: {
                Text(NSLocalizedString("COOL!", comment: "COOL!"))
                    .font(Font.custom("Heebo-SemiBold", size: 21))
                    .foregroundColor(Color("White1"))
                    .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.075, alignment: .center)
                    .background(Color("Red1"))
                    .cornerRadius(50)

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

//struct RewardsView_Previews: PreviewProvider {
//    static var previews: some View {
//        RewardsView()
//    }
//}
