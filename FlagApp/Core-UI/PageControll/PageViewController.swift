import SwiftUI

public struct PageViewController: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIPageViewController

    var controllers: [UIViewController]
    @Binding var currentPage: Int

    public func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        return pageViewController
    }

    public func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        uiViewController.setViewControllers(
            [controllers[currentPage]],
            direction: .forward,
            animated: true
        )
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        let parent: PageViewController

        init(_ parent: PageViewController) {
            self.parent = parent
        }

        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            if let index = parent.controllers.firstIndex(of: viewController), index != 0 {
                return parent.controllers[index - 1]
            }
            return nil
        }

        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            if let index = parent.controllers.firstIndex(of: viewController),
                index + 1 != parent.controllers.count {
                return parent.controllers[index + 1]
            }
            return nil
        }

        public func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController) {
                parent.$currentPage.wrappedValue = index
            }
        }
    }
}
