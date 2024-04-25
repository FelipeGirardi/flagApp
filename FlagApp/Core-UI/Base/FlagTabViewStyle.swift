import Introspect
import SwiftUI

public extension View {
    func tabViewStyle() -> some View {
        modifier(FlagTabViewModifier())
    }
}

private struct FlagTabViewModifier: ViewModifier {
    @EnvironmentObject var theme: Theme

    func body(content: Content) -> some View {
        content
            .introspectTabBarController {
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                appearance.backgroundColor = UIColor(named: "Black1")?.withAlphaComponent(0.35)
                appearance.stackedLayoutAppearance.normal.iconColor = .gray

                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    NSAttributedString.Key.font: UIFont(name: "Heebo-Medium", size: 10) as Any
                ]

                appearance.selectionIndicatorTintColor = .white
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor(named: "White1") as Any
                ]

                $0.tabBar.standardAppearance = appearance

                $0.tabBar.isHidden = self.theme.tabviewHidden
                $0.tabBar.layer.cornerRadius = 25
                $0.tabBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                $0.tabBar.layer.masksToBounds = true

                $0.tabBar.setNeedsLayout()
                $0.tabBar.layoutIfNeeded()
            }
    }
}
