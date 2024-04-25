//
//  LevelProgressScreen.swift
//  FlagApp
//
//  Created by Felipe Girardi on 27/10/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import SwiftUI

public struct LevelProgressScreen: View {
    @EnvironmentObject var appNavigationManager: AppNavigationManager
    let scoreObtained: Int
    private let userManager: UserManager

    @State var didPassLevel: Bool = false
    @State var showPlusPointsLabel: Bool = false
    @State var animateProgressBar: Bool = false
    @State var showCoolButton: Bool = false
    @State var showLevelUpAnimation: Bool = false
    @State var showLevelProgressInfo: Bool = true
    @State var previousLevelPoints: Int = 0
    @State var nextLevelPoints: Int = 0
    @State var previousProgressBarPosition: CGFloat = 0.0
    @State var newProgressBarPosition: CGFloat = 0.0

    @State var dismissView: Bool = false
    private let levelUpSound = Sound(name: "LevelUp_marimbaLoud", type: "mp3")

    public init(scoreObtained: Int, userManager: UserManager) {
        self.scoreObtained = scoreObtained
        self.userManager = userManager
        self._didPassLevel = State(initialValue: self.userManager.challengeData.checkLevelChange(points: self.scoreObtained))
        self._previousLevelPoints = State(initialValue: self.userManager.challengeData.getTotalPointsToNextLevel(level: (self.userManager.challengeData.level ?? 1) - 1))
        self._nextLevelPoints = State(initialValue: self.userManager.challengeData.getTotalPointsToNextLevel(level: self.userManager.challengeData.level ?? 1))
        self._previousProgressBarPosition = State(initialValue: getPreviousProgressBarPosition(score: 0))
        self._newProgressBarPosition = State(initialValue: getNewProgressBarPosition(score: self.scoreObtained))
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    VStack {
                        Spacer(minLength: geometry.size.height * 0.15)

                        levelArea

                        Spacer(minLength: geometry.size.height * 0.08)

                        plusPointsLabel
                            .opacity(self.showPlusPointsLabel ? 1.0 : 0.0)

                        Spacer(minLength: geometry.size.height * 0.03)

                        progressBarArea(geometry: geometry)
                    }

                    Spacer(minLength: geometry.size.height * 0.15)

                    coolButton(geometry: geometry)
                        .opacity(self.showCoolButton ? 1.0 : 0.0)

                    Spacer(minLength: geometry.size.height * 0.06)
                }
                .opacity(self.showLevelProgressInfo ? 1.0 : 0.0)

                if self.showLevelUpAnimation {
                    LevelUpLottie()
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                executeAnimationFlow()
            }
        }
    }

    var levelArea: some View {
        VStack(spacing: 4) {
            Image("Level" + String(userManager.challengeData.level ?? 1))
                .resizable()
                .frame(width: 130, height: 130)

            Text(NSLocalizedString("Level", comment: "Level"))
                .font(Font.custom("Heebo-Bold", size: 32))
                .foregroundColor(Color("Blue1"))
        }
    }

    var plusPointsLabel: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(NSLocalizedString("Challenge completed!", comment: "Challenge completed!"))
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color.white)

            VStack(alignment: .center, spacing: 0) {
                Text("+ \(self.scoreObtained) RP")
                    .font(Font.custom("Heebo-Medium", size: 32))
                    .foregroundColor(Color.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color("Black1"))
        .cornerRadius(10)
    }

    func progressBarArea(geometry: GeometryProxy) -> some View {
        VStack {
            VStack(spacing: 2) {
                HStack {
                    Text(String(self.previousLevelPoints))
                    Spacer()
                    Text(String(self.nextLevelPoints))
                }
                .padding(.horizontal, 30)

                progressBar(geometry: geometry)
            }

            Text(NSLocalizedString("Level progress", comment: "Level progress"))
                .font(Font.custom("Heebo-Regular", size: 14))
                .foregroundColor(Color.white)
        }
    }

    func progressBar(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(Color("Red2"))
                .fixedSize(horizontal: false, vertical: false)
                .frame(maxWidth: geometry.size.width * 0.75, maxHeight: 12)
            RoundedRectangle(cornerRadius: 6)
                .foregroundColor(Color("Red1"))
                .fixedSize(horizontal: false, vertical: false)
                .frame(maxWidth: self.animateProgressBar ? (geometry.size.width * 0.75) * self.newProgressBarPosition : (geometry.size.width * 0.75) * self.previousProgressBarPosition)
                //.animation(.easeInOut(duration: 1))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [Color("Red3"), Color("Red1")]), startPoint: .top, endPoint: .bottom)
                        )
                )
        }
        .fixedSize(horizontal: false, vertical: false)
        .frame(width: geometry.size.width * 0.75, height: 12)
    }

    func coolButton(geometry: GeometryProxy) -> some View {
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
                    .frame(width: geometry.size.width - 36, height: geometry.size.height * 0.075)
                    .background(Color("Red1"))
                    .cornerRadius(50)

                NavigationLink(
                    destination: RewardsView(userManager: self.userManager),
                    isActive: self.$dismissView
                ) {
                    EmptyView()
                }
                .isDetailLink(false)
            }
        )
    }

    func getPreviousProgressBarPosition(score: Int) -> CGFloat {
        CGFloat(((self.userManager.challengeData.totalPoints ?? 0) - score) - self.previousLevelPoints) / CGFloat((self.nextLevelPoints - self.previousLevelPoints))
    }

    func getNewProgressBarPosition(score: Int) -> CGFloat {
        CGFloat(((self.userManager.challengeData.totalPoints ?? 0) + score) - self.previousLevelPoints) / CGFloat(self.nextLevelPoints - self.previousLevelPoints)
    }

    func executeAnimationFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            withAnimation(.easeInOut(duration: 1.0)) {
                // show points obtained
                self.showPlusPointsLabel = true
            }
        }
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            withAnimation(.easeInOut(duration: 1.0)) {
                // activate progress bar animation
                self.animateProgressBar = true
            }
        }
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            withAnimation(.easeInOut(duration: 1.0)) {
                if self.didPassLevel {
                    // activate level up animation
                    self.showLevelUpAnimation = true
                    playSound(sound: self.levelUpSound)
                } else {
                    // no level up: only update points
                    self.userManager.challengeData.addPoints(points: self.scoreObtained)
                    self.showCoolButton = true
                }
            }
        }
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5, execute: {
            // level up: update points, level and progress bar info
            if self.didPassLevel {
                self.showLevelProgressInfo = false
                updateChallengeDataAfterLevelUp()
            }
        }
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5, execute: {
            // end level up animation
            if self.didPassLevel {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.showLevelUpAnimation = false
                    self.showLevelProgressInfo = true
                }
            }
        }
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5, execute: {
            // end level up animation
            if self.didPassLevel {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.animateProgressBar = true
                }
            }
        }
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5, execute: {
            // end level up animation
            if self.didPassLevel {
                withAnimation(.easeInOut(duration: 1.0)) {
                    self.showCoolButton = true
                }
            }
        }
        )
    }

    func updateChallengeDataAfterLevelUp() {
        self.userManager.challengeData.addPoints(points: self.scoreObtained)
        self.userManager.challengeData.changeLevel()
        self.previousLevelPoints = self.userManager.challengeData.getTotalPointsToNextLevel(level: (self.userManager.challengeData.level ?? 1) - 1)
        self.nextLevelPoints = self.userManager.challengeData.getTotalPointsToNextLevel(level: self.userManager.challengeData.level ?? 1)

        withAnimation(.easeInOut(duration: 0.1)) {
            self.previousProgressBarPosition = 0.0
            self.newProgressBarPosition = getNewProgressBarPosition(score: 0)
            self.animateProgressBar = false
        }
    }
}

struct LevelProgressScreen_Previews: PreviewProvider {
    static var previews: some View {
        LevelProgressScreen(scoreObtained: 10, userManager: UserManager())
    }
}
