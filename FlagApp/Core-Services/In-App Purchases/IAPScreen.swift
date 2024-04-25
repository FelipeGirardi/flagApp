//
//  IAPScreen.swift
//  FlagApp
//
//  Created by Felipe Girardi on 12/11/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import StoreKit
import SwiftUI

struct IAPScreen: View {
    @ObservedObject private var viewModel: IAPViewModel
    @State var products: [SKProduct] = []

    init (viewModel: IAPViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 35) {
                HStack {
                    HStack {
                        Image("peakTokenBig")
                            .resizable()
                            .frame(width: 19, height: 19)

                        Text(NSLocalizedString("Purchase", comment: "Purchase"))
                            .font(Font.custom("Heebo-Bold", size: 15))
                            .foregroundColor(Color("Gray2"))
                    }

                    Spacer()

                    Button(
                        action: { self.viewModel.showIAPScreen = false },
                        label: {
                            Image("dismissChallenge-icon")
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                    )
                }

                VStack(spacing: 12) {
                    HStack {
                        Text(NSLocalizedString("Token Packs", comment: "Token Packs"))
                            .font(Font.custom("Heebo-Medium", size: 17))
                            .foregroundColor(Color("Red1"))

                        Spacer()
                    }

                    if self.products.isEmpty {
                        VStack {
                            Spacer()

                            Text(NSLocalizedString("Loading products...", comment: "Loading products..."))
                                .font(Font.custom("Heebo-Regular", size: 14))
                                .foregroundColor(Color.white)
                                .padding()

                            Spacer()

                            ActivityIndicator(isAnimating: .constant(true), style: .large)

                            Spacer()
                        }
                    } else {
                        ForEach(self.products.indices, id: \.self) { productIndex in
                            productCell(product: products[productIndex], productIndex: productIndex + 1)
                        }
                    }
                }
            }
            .padding(11)
        }
        .background(
            Color("Black4")
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "#2C2E33"), lineWidth: 1)
                )
        )
        .cornerRadius(14)
        .onAppear {
            viewModel.iapManager.requestProducts { success, products in
                if success {
                    self.products = products!.sorted { Double(truncating: $0.price) < Double(truncating: $1.price) }
                }
            }
        }
    }

    func productCell(product: SKProduct, productIndex: Int) -> some View {
        ZStack {
            Color(productIndex == 2 ? "Gray7" : "Black3")

            HStack {
                Image("tokenIAP_\(productIndex)")
                    .resizable()
                    .frame(width: (productIndex == 3) ? 63 : 56, height: productIndex == 1 ? 52 : 80)

                Spacer()

                VStack(alignment: .center, spacing: 0) {
                    if productIndex == 2 {
                        Text("BEST BARGAIN!")
                            .font(Font.custom("Heebo-Regular", size: 7))
                            .foregroundColor(Color.white)
                            .padding([.top, .bottom], 2)
                            .padding([.leading, .trailing], 5)
                            .background(Color("Yellow1"))
                            .cornerRadius(3)
                    }

                    VStack(spacing: -8) {
                        HStack(alignment: .center, spacing: 8) {
                            if productIndex == 2 {
                                Text("200 ")
                                    .font(Font.custom("Heebo-Medium", size: 19))
                                    .foregroundColor(Color("Purple1"))
                                    .strikethrough(color: Color("Purple1"))
                            }

                            Text(String(self.viewModel.iapManager.getProductValueInCoins(productID: product.productIdentifier)))
                                .font(Font.custom("Heebo-Bold", size: 35))
                                .foregroundColor(productIndex == 2 ? Color("Purple1") : Color("Blue1"))
                        }

                        Text("Peak Tokens")
                            .font(Font.custom("Heebo-Regular", size: 18))
                            .foregroundColor(productIndex == 2 ? Color("Purple1") : Color("Blue1"))
                    }
                }

                Spacer()

                if IAPManager.canMakePayments() {
                    Button(
                        action: { viewModel.iapManager.buyProduct(product) },
                        label: {
                            Text("\(product.localizedPrice)")
                                .font(Font.custom("Heebo-SemiBold", size: 27))
                                .foregroundColor(Color.white)
                                .frame(minWidth: 115, minHeight: 75)
                                .background(Color("Red1"))
                                .cornerRadius(10)
                        }
                    )
                } else {
                    Text(NSLocalizedString("Not available.", comment: "Not available."))
                        .font(Font.custom("Heebo-Regular", size: 14))
                        .foregroundColor(Color("Red1"))
                }
            }
            .padding(8)
        }
        .cornerRadius(13)
        .frame(height: 90)
        .padding([.top, .bottom], 10)
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
