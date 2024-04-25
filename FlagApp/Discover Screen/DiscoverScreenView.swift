import SwiftUI

struct DiscoverScreenView: View {
    private let userManager: UserManager

    init(userManager: UserManager) {
        self.userManager = userManager
    }

    func searchIcon() -> some View {
        Button(action: {
            // Action
        }, label: {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(.white)
        }
        )
    }

    var body: some View {
            NavigationView {
                ZStack {
                    Color("Black2")
                        .edgesIgnoringSafeArea(.all)

                    List {
                        ForEach(trendingInfos.indices, id: \.self) { index in
                            TrendingView(trendingInfo: trendingInfos[index])
                        }
                    }

                    ChallengesListView(viewModel: .init(), userManager: userManager)    // slider
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarTitle(Text("Discover"))
                .navigationBarItems(trailing: self.searchIcon())
            }
    }
}

struct DiscoverScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverScreenView(userManager: .init())
    }
}
