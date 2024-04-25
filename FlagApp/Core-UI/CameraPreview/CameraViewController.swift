import AVFoundation
import Combine
import Photos
import SwiftUI
import UIKit

class CameraViewController: UIViewController {
    // Camera Session dependency
    let cameraSession: CameraSessionManager
    var cancellables = Set<AnyCancellable>()

    init(
        cameraSession: CameraSessionManager
    ) {
        self.cameraSession = cameraSession
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var previewView: PreviewView!
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?

    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!

    var windowOrientation: UIInterfaceOrientation {
        view.window?.windowScene?.interfaceOrientation ?? .unknown
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addPreviewView()
        setupConstraints()

        // Set up the video preview view.
        previewView.session = cameraSession.session

        // Listen when preview can be started
        cameraSession
            .startCameraSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                guard let self = self
                else {
                    return
                }
                var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                if self.windowOrientation != .unknown {
                    if let videoOrientation = AVCaptureVideoOrientation(rawValue: self.windowOrientation.rawValue) {
                        initialVideoOrientation = videoOrientation
                    }
                }
                self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                self.cameraSession.start()
            }
        )
        .store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func addPreviewView() {
        previewView = PreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.addSubview(previewView)
    }
    private func setupConstraints() {
        previewView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

private extension CameraViewController {
    // MARK: Session Management
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait

        case .portraitUpsideDown:
            self = .portraitUpsideDown

        case .landscapeLeft:
            self = .landscapeRight

        case .landscapeRight:
            self = .landscapeLeft

        default:
            return nil
        }
    }

    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait:
            self = .portrait

        case .portraitUpsideDown:
            self = .portraitUpsideDown

        case .landscapeLeft:
            self = .landscapeLeft

        case .landscapeRight:
            self = .landscapeRight

        default:
            return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions = [AVCaptureDevice.Position]()

        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        return uniqueDevicePositions.count
    }
}
