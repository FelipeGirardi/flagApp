//import SwiftUI
//
// content you want your app to display goes here
//struct RankingView: View {
//    @EnvironmentObject var gameCenter: GameKitHelper
//
//    @State private var selectorIndex = 0
//    @State private var tabs = ["Users", "Leaderboard"]
//
//    @State private var isShowingGameCenter = false {
//        didSet {
//            PopupControllerMessage
//                .gameCenter
//                .postNotification()
//            }
//    }
//
//    var body: some View {
//        VStack {
//            Picker("Numbers", selection: $selectorIndex) {
//                ForEach(0 ..< tabs.count) { index in
//                    Text(self.tabs[index]).tag(index)
//                }
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding()
//
//            Spacer()
//            getTabView()
//
//            if self.gameCenter.enabled {
//                Button(
//                    action: { self.isShowingGameCenter.toggle() }
//                ) {
//                    Text("Press to show leaderboards and achievements")
//                }
//            }
//        }
//    }
//
//    private func getTabView() -> some View {
//        if selectorIndex == 0 {
//            return AnyView(Color.red)
//        } else {
//            return AnyView(LeaderboardView(viewModel: LeaderboardViewModel()))
//        }
//    }
//}
