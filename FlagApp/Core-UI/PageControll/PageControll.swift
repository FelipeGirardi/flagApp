import Foundation
import SwiftUI
import UIKit

public struct PageControl: UIViewRepresentable {
    @Binding var currentPage: Int
    let numberOfPages: Int

    public init(
        currentPage: Binding<Int>,
        numberOfPages: Int
    ) {
        self._currentPage = currentPage
        self.numberOfPages = numberOfPages
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged
        )
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = .white
        return control
    }

    public func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    public class Coordinator: NSObject {
        var control: PageControl

        public init(_ control: PageControl) {
            self.control = control
        }

        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
