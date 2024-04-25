//
//  InterstitialAd.swift
//  FlagApp
//
//  Created by Luiz Antonio Bolsoni Riboli on 11/11/20.
//  Copyright © 2020 Flag. All rights reserved.
//
import GoogleMobileAds
import SwiftUI
import UIKit

final class InterstitialAd: NSObject, GADInterstitialDelegate {
    var interstitial: GADInterstitial = GADInterstitial(adUnitID: "ca-app-pub-8740498287885875/4600691034")

    override init() {
        super.init()
        loadInterstitial()
    }

    func loadInterstitial() {
        let req = GADRequest()
        self.interstitial.load(req)
        self.interstitial.delegate = self
    }

    func showAd() {
        if self.interstitial.isReady {
           let root = UIApplication.shared.windows.first?.rootViewController
           self.interstitial.present(fromRootViewController: root!)
        } else {
            print("Not Ready")
        }
    }

    // swiftlint:disable identifier_name
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.interstitial = GADInterstitial(adUnitID: "ca-app-pub-8740498287885875/4600691034")
        loadInterstitial()
    }
}

struct ContentView: View {
    var interstitial: InterstitialAd

    init() {
        self.interstitial = InterstitialAd()
    }

    var body: some View {
      Button(
        action: {
            self.interstitial.showAd()
        }, label: {
            Text("My Button")
        }
      )
    }
}
