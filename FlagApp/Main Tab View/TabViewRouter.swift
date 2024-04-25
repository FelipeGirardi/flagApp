import Foundation
import SwiftUI

public class TabViewRouter: ObservableObject {
    @Published var selectedTab: Tab = .challenges
}

public extension TabViewRouter {
    enum Tab: Hashable {
        case challenges
        case notification
        case profile
        case ranking
    }
}
