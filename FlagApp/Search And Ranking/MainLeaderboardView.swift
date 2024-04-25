//
//  LeaderboardView.swift
//  FlagApp
//
//  Created by Felipe Girardi on 29/10/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import SwiftUI

struct MainLeaderboardView: View {
    private let viewModel: LeaderboardViewModel
    init(viewModel: LeaderboardViewModel) {
        self.viewModel = viewModel
    }
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            VStack(alignment: .leading, spacing: 15) {
                Image("GameCenterLogo")
                    .frame(width: 156, height: 156)

                Text(NSLocalizedString("Our leaderboard is connected via Game Center!", comment: "Our leaderboard is connected via Game Center!"))
                    .font(Font.custom("Heebo-Bold", size: 30))
                    .foregroundColor(Color.white)
                    .frame(minWidth: 0, maxWidth: 270)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: {
                viewModel.authGameCenter()
            }, label: {
                HStack(spacing: 10) {
                    Image("GameCenterLogoSmall")
                        .frame(width: 24, height: 24)

                    Text(NSLocalizedString("Connect to Game Center", comment: "Connect to Game Center"))
                        .font(Font.custom("Heebo-Medium", size: 19))
                        .foregroundColor(Color.black)
                }
            }
            )
            .frame(width: 300, height: 44)
            .background(Color.white)
            .cornerRadius(6)
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal)
    }
}
