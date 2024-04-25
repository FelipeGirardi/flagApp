import SwiftUI

/// Use it on swiftUI screen
struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController

    let cameraSessionManager: CameraSessionManager

    func makeUIViewController(context: Context) -> UIViewControllerType {
        CameraViewController(
            cameraSession: cameraSessionManager
        )
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    }
}
