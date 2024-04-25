import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var gameCenter: GameKitHelper
    @ObservedObject var viewModel: LeaderboardViewModel
    private let userManager: UserManager
    @State var isLoading: Bool = true
    @State var didLoadLeaderboard = false
    let geometry: GeometryProxy

    init(viewModel: LeaderboardViewModel, userManager: UserManager, geometry: GeometryProxy) {
        self.viewModel = viewModel
        self.userManager = userManager
        self.geometry = geometry
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if self.isLoading && !self.viewModel.isUserAuthenticated {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    if !viewModel.isUserAuthenticated {
                        MainLeaderboardView(viewModel: viewModel)
                    } else {
                        VStack {
                            ZStack(alignment: .center) {
                                top3FlagsAndNames(geometry: geometry)
                                    .opacity(viewModel.leaderboardScores.isEmpty ? 0.0 : 1.0)

                                Image("mountainsRanking")
                                    .resizable()
                                    .frame(height: geometry.size.height * 0.5)
                                    .edgesIgnoringSafeArea(.horizontal)
                                    .padding(.leading, -(geometry.size.width * 0.12))
                                    .padding(.trailing, -(geometry.size.width * 0.193))
                                    .offset(y: geometry.size.height * 0.056)
                            }

                            if !self.didLoadLeaderboard && self.viewModel.leaderboardScores.isEmpty {
                                Spacer()
                                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                                Spacer()
                            } else {
                                leaderboardList(geometry: geometry)
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.getLeaderboard {
                    self.isLoading = false
                }
                viewModel.getScores {
                    self.didLoadLeaderboard = true
                }
            }
        }
    }

    func top3FlagsAndNames(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            VStack(spacing: geometry.size.height * 0.075) {
                Image("FlagIconPurpleBig")
                    .resizable()
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.1)
                Text(viewModel.leaderboardScores.isEmpty ? "-" : viewModel.leaderboardScores[1].playerName)
                    .opacity(viewModel.leaderboardScores.isEmpty ? 0.0 : 1.0)
                    .font(Font.custom("Heebo-Medium", size: geometry.size.width * 0.04))
                    .foregroundColor(Color.white)
            }
            .offset(x: -(geometry.size.width * 0.03), y: -(geometry.size.width * 0.01))

            Spacer()

            VStack(spacing: geometry.size.height * 0.075) {
                Image("FlagIconRedBig")
                    .resizable()
                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.123)
                Text(viewModel.leaderboardScores.isEmpty ? "-" : viewModel.leaderboardScores[0].playerName)
                    .opacity(viewModel.leaderboardScores.isEmpty ? 0.0 : 1.0)
                    .font(Font.custom("Heebo-Medium", size: geometry.size.width * 0.04))
                    .foregroundColor(Color.white)
            }
            .offset(x: -(geometry.size.width * 0.028), y: -(geometry.size.height * 0.15))

            Spacer()

            VStack(spacing: geometry.size.height * 0.08) {
                Image("FlagIconCyanBig")
                    .resizable()
                    .frame(width: geometry.size.width * 0.15, height: geometry.size.height * 0.078)
                Text(viewModel.leaderboardScores.isEmpty ? "-" : viewModel.leaderboardScores[2].playerName)
                    .opacity(viewModel.leaderboardScores.isEmpty ? 0.0 : 1.0)
                    .font(Font.custom("Heebo-Medium", size: geometry.size.width * 0.04))
                    .foregroundColor(Color.white)
            }
            .offset(x: -((geometry.size.width * 0.016)), y: geometry.size.height * 0.045)

            Spacer()
        }
    }

    func leaderboardList(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            HStack {
                Text("PLACE")
                    .font(Font.custom("Heebo-Bold", size: 15))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: geometry.size.width * 0.24, alignment: .center)

//                Text("FLAG")
//                    .font(Font.custom("Heebo-Bold", size: 15))
//                    .foregroundColor(Color.white)
//                    .multilineTextAlignment(.center)
//                    .minimumScaleFactor(0.75)
//                    .frame(maxWidth: 35, alignment: .center)

                Text("USER")
                    .font(Font.custom("Heebo-Bold", size: 15))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("RP")
                    .font(Font.custom("Heebo-Bold", size: 15))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: geometry.size.width * 0.24, alignment: .center)
            }

            if #available(iOS 14.0, *) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .center) {
                        mainLeaderboard(geometry: geometry)
                    }
                    .listStyle(PlainListStyle())
                }
            } else {
                List {
                    mainLeaderboard(geometry: geometry)
                }
            }
        }
    }

    func mainLeaderboard(geometry: GeometryProxy) -> some View {
        ForEach(viewModel.leaderboardScores) { leaderboardScore in
            HStack {
                Text("# \(leaderboardScore.rank)")
                    .font(Font.custom("Heebo-Bold", size: 17))
                    .foregroundColor(Color("Purple1"))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: geometry.size.width * 0.24, alignment: .center)

//                Image("grayFlag")
//                    .resizable()
//                    .frame(width: 35, height: 35, alignment: .center)

                Text(leaderboardScore.playerName)
                    .font(Font.custom("Heebo-Medium", size: 17))
                    .foregroundColor(Color.white)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("\(leaderboardScore.score)")
                    .font(Font.custom("Heebo-Bold", size: 17))
                    .foregroundColor(Color("Purple1"))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .frame(maxWidth: geometry.size.width * 0.24, alignment: .center)
            }
            .padding(.vertical, 1)
        }
    }
}
