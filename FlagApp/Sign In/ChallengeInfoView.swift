import SwiftUI

struct ChallengeInfoView: View {
    private var userManager: UserManager
    private var challengeData: ChallengeData
    var geometry: GeometryProxy
    var previousLevelPoints: Int
    var nextLevelPoints: Int

    init(userManager: UserManager, challengeData: ChallengeData, geometry: GeometryProxy) {
        self.userManager = userManager
        self.challengeData = challengeData
        self.geometry = geometry
        self.previousLevelPoints = self.challengeData.getTotalPointsToNextLevel(level: (self.challengeData.level ?? 1) - 1)
        self.nextLevelPoints = self.challengeData.getTotalPointsToNextLevel(level: self.challengeData.level ?? 1)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("\(challengeData.totalPoints ?? 0) RP")
                .font(Font.custom("Heebo-Bold", size: 24))
                .foregroundColor(Color.white)

            HStack(spacing: 12) {
                Image("Level" + String(describing: challengeData.level ?? 1))
                    .resizable()
                    .frame(width: 76, height: 76)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 5) {
                        HStack {
                            Text("📈")
                            // MARK: level 19 doesn't update label because it's the last level available for now
                            Text((challengeData.level ?? 1) != 19 ? "\(challengeData.getPointsToNextLevel(points: 0)) RP" : "\(pointsToNextLevel * (challengeData.level ?? 1)) RP")
                                .font(Font.custom("Heebo-Regular", size: 14))
                                .foregroundColor(Color.white)
                                .minimumScaleFactor(0.8)
//                            Text(NSLocalizedString("More levels coming soon!", comment: "More levels coming soon!"))
//                                .font(Font.custom("Heebo-Regular", size: 14))
//                                .foregroundColor(Color.white)
                        }
                        Text(NSLocalizedString("Until next level", comment: "Until next level"))
                            .font(Font.custom("Heebo-Regular", size: 14))
                            .foregroundColor(Color("Gray3"))
                    }

                    HStack(spacing: 5) {
                        HStack {
                            Image("peakTokenBig")
                                .resizable()
                                .frame(width: 20, height: 20)

                            Text("\(userManager.profile?.cash ?? 0) Peak Tokens")
                                .font(Font.custom("Heebo-Regular", size: 14))
                                .foregroundColor(Color.white)
                                .minimumScaleFactor(0.8)
                        }

                        Text(NSLocalizedString("Available", comment: "Available"))
                                .font(Font.custom("Heebo-Regular", size: 14))
                                .foregroundColor(Color("Gray3"))
                    }

                    progressBarArea(geometry: geometry)
                }
                // MARK: achievement area (not in MVP)
                //achievementBarArea
            }
        }
    }

    func progressBarArea(geometry: GeometryProxy) -> some View {
        VStack(spacing: 2) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color("Gray4"))
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color("Red1"))
                    .frame(width: (geometry.size.width * 0.65) * getProgressPercentage())
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [Color("Red3"), Color("Red1")]), startPoint: .top, endPoint: .bottom)
                            )
                    )
            }
            .frame(width: geometry.size.width * 0.65, height: 12)

            HStack {
                Text(String(self.previousLevelPoints))
                    .font(Font.custom("Heebo-Regular", size: 14))
                    .foregroundColor(Color("Gray3"))

                Spacer()

                Text(String(self.nextLevelPoints))
                    .font(Font.custom("Heebo-Regular", size: 14))
                    .foregroundColor(Color("Gray3"))
            }
        }
        .frame(width: geometry.size.width * 0.65)
    }

    func getProgressPercentage() -> CGFloat {
        CGFloat((self.challengeData.totalPoints ?? 0) - self.previousLevelPoints) / CGFloat(self.nextLevelPoints - self.previousLevelPoints)
    }

    var achievementBarArea: some View {
        VStack(alignment: .leading) {
            ZStack {
                Image("mockAchievementBar2")
                    .resizable()
                    .frame(width: 278, height: 12)
                Image("mockAchievementBar1")
                    .resizable()
                    .frame(width: 214, height: 12)
                    .offset(x: -32)
            }

            HStack {
                Text("\(challengeData.totalPoints ?? 0) RP")
                    .font(Font.custom("Heebo-Regular", size: 14))
                    .foregroundColor(Color("Gray1"))

                Spacer()

                Text("\((((challengeData.totalPoints ?? 0) / 1_000) + 1) * 1_000) RP")
                    .font(Font.custom("Heebo-Regular", size: 14))
                    .foregroundColor(Color("Gray1"))
                    .padding(.trailing, 10)
            }
        }
    }
}

// MARK: inner shadow extension

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
    }
}
