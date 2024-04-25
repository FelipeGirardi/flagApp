//
//  PreAdView.swift
//  FlagApp
//
//  Created by Luiz Antonio Bolsoni Riboli on 16/11/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import SwiftUI

public struct PreAdView: View {
    @EnvironmentObject var appNavigationManager: AppNavigationManager
    @Environment(\.presentationMode) var presentationMode

    @State private var opacity: Double = 1
    var interstitial: InterstitialAd

    public init() {
        // MARK: Ad Settings
        self.interstitial = InterstitialAd()
    }

    public var body: some View {
        VStack(alignment: .center) {
            Spacer()

            mainLabel
                .opacity(opacity)
                .padding(20)

            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .background(
            Color(hex: "#331481")
                .aspectRatio(contentMode: .fill)
                .overlay(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(false)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    self.opacity = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                self.appNavigationManager.moveToChallengeList = true

                // MARK: Ad Settings
                interstitial.showAd()
            }
        }
    }

    private var mainLabel: some View {
        Text(NSLocalizedString("Flag is free", comment: "Flag is free"))
            .font(Font.custom("Heebo-Bold", size: 34))
            .multilineTextAlignment(.center)
            .foregroundColor(Color("White1"))
            .padding(.top, 50)
    }
}

struct PreAdView_Previews: PreviewProvider {
    static var previews: some View {
        PreAdView()
    }
}
