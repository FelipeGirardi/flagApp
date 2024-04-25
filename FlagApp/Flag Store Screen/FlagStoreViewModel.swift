import Combine
import Foundation
import SwiftUI

public struct FlagCard: Identifiable {
    public var id: String
    let category: String
    let name: String
    var imageName: String
    let price: Int
    var isBought: Bool
}

public struct ConsumableFlag: Identifiable {
    public var id: String
    let flagRows: [[FlagCard]]
}

public final class FlagStoreViewModel: ObservableObject {
    @ObservedObject var userManager: UserManager
    var iapManager: IAPManager
    @Published var isShowingBuyFlagView: Bool = false
    @Published var isBuyingFlag: Bool = false
    @Published var myFlagAssetName: String?
    @Published var selectedFlag: FlagCard?
    @Published var totalCash: Int = 0
    @Published var isBuyButtonEnabled: Bool = true
    @Published var selectedFlagToBuy: FlagCard?
    private var cancellables = Set<AnyCancellable>()

    // Used to present the flag section. In this order it will appear on screen
    let consumableFlags: [ConsumableFlag] = [.country, .pride] // [ [[]], [[]] ]

    init(userManager: UserManager, iapManager: IAPManager) {
        self.userManager = userManager
        self.iapManager = iapManager
        self.myFlagAssetName = userManager.profile?.profileSelectedFlagName

        self.selectedFlag = consumableFlags.compactMap { consumableFlag -> FlagCard? in
            consumableFlag.flagRows.flatMap { $0 }
                .first { $0.imageName == myFlagAssetName }
        }.first

        userManager.$profile.sink { [weak self] profile in
            guard let profile = profile,
                  let self = self
            else {
                return
            }
            self.totalCash = profile.cash ?? 0
        }
            .store(in: &cancellables)

        $selectedFlagToBuy.sink { [weak self] selectedFlag in
            guard let selectedFlag = selectedFlag,
                  let self = self
            else {
                return
            }
            self.isBuyButtonEnabled = self.totalCash >= selectedFlag.price
        }
        .store(in: &cancellables)
    }

    func buySelectedFlag() {
        guard let userCash = userManager.profile?.cash,
              let flag = selectedFlagToBuy else {
            return
        }
        self.isBuyingFlag = true
        if userCash >= flag.price {

            self.userManager
                .buyFlag(newFlagID: flag.id, selectedFlagName: flag.imageName)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case let .failure(error):
                            // TODO: Present error alert and ask user retry later
                            switch error {
                            case .profileNotFound:
                                break

                            case .unknown:
                                break

                            case .updateCash:
                                break
                            }
                            self.isBuyingFlag = false

                        case .finished:
                            // show flag faster on screen
                            self.selectedFlag? = flag
                            self.isBuyingFlag = false
                        }
                    }, receiveValue: { [weak self] _ in
                        self?.userManager.updateCash(withValue: -(flag.price))
                        self?.userManager.profile?.profileSelectedFlagName = flag.imageName
                        self?.isShowingBuyFlagView = false
                        self?.isBuyingFlag = false
                        self?.myFlagAssetName = flag.imageName
                    }
                )
                .store(in: &cancellables)
        } else {
            //TODO: Present alert saying that user has not suficient cash to by it
            self.isBuyingFlag = false
            self.isShowingBuyFlagView = false
        }
    }

    func selectFlag(flagName: String) {
        self.userManager
            .selectFlag(selectedFlagName: flagName)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error):
                        // TODO: Present error alert and ask user retry later
                        switch error {
                        case .profileNotFound:
                            break

                        case .unknown:
                            break

                        case .updateCash:
                            break
                        }

                    case .finished:
                        break
                    }
                }, receiveValue: { _ in
//                    self?.userManager.profile?.profileSelectedFlagName = flagName
//                    self?.myFlagAssetName = flagName
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: not being used (can't localize enums)
public extension ConsumableFlag {
    enum Category: String {
        case countries = "Countries"
        case pride = "Pride"
        case memes = "Memes"
        case soccerTeams = "Soccer Teams"
    }
}

// MARK: - List of consumable flags
public extension ConsumableFlag {
    static let country = ConsumableFlag(
        id: NSLocalizedString("Countries", comment: "Countries"),
        flagRows:
            [
                [.brazil, .usa, .italy, .indonesia] // Max of 4 flags per row
            ]
    )

    static let pride = ConsumableFlag(
        id: NSLocalizedString("Pride", comment: "Pride"),
        flagRows:
            [
                [.lgbt, .blackLivesMatter, .feminism, .respect] // Max of 4 flags per row
            ]
    )
}

public extension FlagCard {
    // MARK: - Country flags
    static let brazil = FlagCard(
        id: "01",
        category: NSLocalizedString("Countries", comment: "Countries"),
        name: NSLocalizedString("Brazil", comment: "Brazil"),
        imageName: "brazil_flag",
        price: 100,
        isBought: false
    )

    static let usa = FlagCard(
        id: "02",
        category: NSLocalizedString("Countries", comment: "Countries"),
        name: NSLocalizedString("USA", comment: "USA"),
        imageName: "usa_flag",
        price: 100,
        isBought: false
    )

    static let italy = FlagCard(
        id: "03",
        category: NSLocalizedString("Countries", comment: "Countries"),
        name: NSLocalizedString("Italy", comment: "Italy"),
        imageName: "italy_flag",
        price: 100,
        isBought: false
    )

    static let indonesia = FlagCard(
        id: "04",
        category: NSLocalizedString("Countries", comment: "Countries"),
        name: NSLocalizedString("Indonesia", comment: "Indonesia"),
        imageName: "indonesia_flag",
        price: 100,
        isBought: false
    )

    // MARK: - Pride flags
    static let lgbt = FlagCard(
        id: "05",
        category: NSLocalizedString("Pride", comment: "Pride"),
        name: "LGBT+",
        imageName: "lbgt_flag",
        price: 150,
        isBought: false
    )

    static let blackLivesMatter = FlagCard(
        id: "06",
        category: NSLocalizedString("Pride", comment: "Pride"),
        name: NSLocalizedString("Black Lives Matter", comment: "Black Lives Matter"),
        imageName: "blm_flag",
        price: 150,
        isBought: false
    )

    static let feminism = FlagCard(
        id: "07",
        category: NSLocalizedString("Pride", comment: "Pride"),
        name: NSLocalizedString("Feminism", comment: "Feminism"),
        imageName: "feminism_flag",
        price: 150,
        isBought: false
    )

    static let respect = FlagCard(
        id: "08",
        category: NSLocalizedString("Pride", comment: "Pride"),
        name: NSLocalizedString("Peace", comment: "Peace"),
        imageName: "peace_flag",
        price: 150,
        isBought: false
    )
}
