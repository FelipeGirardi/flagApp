//
//  IAPHelper.swift
//  FlagApp
//
//  Created by Felipe Girardi on 12/11/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import StoreKit

public typealias ProductID = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
  static let IAPManagerPurchaseNotification = Notification.Name("IAPManagerPurchaseNotification")
}

open class IAPManager: NSObject {
    public static let oneHundredPeakTokens = "flag.FlagApp.100PeakTokens"
    public static let threeHundredPeakTokens = "flag.FlagApp.300PeakTokens"
    public static let oneThousandPeakTokens = "flag.FlagApp.1000PeakTokens"

    private let productIDs: Set<ProductID> = [oneHundredPeakTokens, threeHundredPeakTokens, oneThousandPeakTokens]
    private var purchasedProductIdentifiers: Set<ProductID> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var userManager: UserManager

    public init(userManager: UserManager) {
        self.userManager = userManager
        for productIdentifier in productIDs {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }

    // MARK: - StoreKit API

    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler

        productsRequest = SKProductsRequest(productIdentifiers: productIDs)
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    public func isProductPurchased(_ productIdentifier: ProductID) -> Bool {
        purchasedProductIdentifiers.contains(productIdentifier)
    }

    public class func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPManager: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products

        if !products.isEmpty {
            for item in products {
                print("Found product: \(item.productIdentifier) \(item.localizedTitle) \(item.price.floatValue)")
            }
        } else {
            print("No products found")
            print(response.invalidProductIdentifiers)
        }

        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)

            case .failed:
                fail(transaction: transaction)

            case .restored:
                restore(transaction: transaction)

            case .deferred:
                break

            case .purchasing:
                break

            @unknown default:
                break
            }
        }
    }

    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        self.userManager.updateCash(withValue: getProductValueInCoins(productID: transaction.payment.productIdentifier))
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            return
        }

        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription, transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction Error: \(localizedDescription)")
            }

        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else {
            return
        }

//      purchasedProductIdentifiers.insert(identifier)
//      UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPManagerPurchaseNotification, object: identifier)
    }

    func getProductValueInCoins(productID: String) -> Int {
        switch productID {
        case IAPManager.oneHundredPeakTokens:
            return 100

        case IAPManager.threeHundredPeakTokens:
            return 300

        case IAPManager.oneThousandPeakTokens:
            return 1_000

        default:
            return 0
        }
    }
}
