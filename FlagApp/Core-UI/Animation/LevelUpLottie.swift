//
//  LevelUpLottie.swift
//  FlagApp
//
//  Created by Felipe Girardi on 23/10/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import SwiftUI

struct LevelUpLottie: View {
    var body: some View {
        VStack {
            LottieView(filename: "lvlUP_animation")
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
        .edgesIgnoringSafeArea(.all)
    }
}
