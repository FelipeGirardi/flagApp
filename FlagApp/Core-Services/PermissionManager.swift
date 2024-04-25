import AVFoundation
import Combine
import Foundation
import SwiftUI

class PermissionManager: ObservableObject {
    @Published var isCameraAutorized: Bool = false
    @Published var enableAnimationCameraPermission = false

    // MARK: Microphone permission check - DO NOT DELETE (to be implemented)
//    var isMicrophoneAutorized: Bool = false

    func cameraPermissionStatus() -> AVAuthorizationStatus? {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            return .authorized
        } else if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
            return .denied
        } else if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.notDetermined {
            return .notDetermined
        } else if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.restricted {
            return .restricted
        } else {
            return nil
        }
    }

    func activateCameraPermissionRequest(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            // Dispatch prevents publishing changes from background threads (that are not allowed)
            DispatchQueue.main.async {
                self.isCameraAutorized = true
            }
            return

        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.enableAnimationCameraPermission = true
                        completion(true)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        self.isCameraAutorized = true
                    }
                    return
                }
            }

        case .denied: // The user has previously denied access.
            DispatchQueue.main.async {
                self.isCameraAutorized = false
                completion(false)
            }
            return

        case .restricted: // The user can't grant access due to restrictions.
            DispatchQueue.main.async {
                self.isCameraAutorized = false
            }
            return

        @unknown default:
            return
        }
    }

    // MARK: Microphone permission check - DO NOT DELETE (to be implemented)
//    func checkMicrophonePermission() {
//        AVAudioSession.sharedInstance().requestRecordPermission { granted in
//            if granted {
//                self.isMicrophoneAutorized = true
//            } else {
//                self.isMicrophoneAutorized = false
//                // Present message to user indicating that recording
//                // can't be performed until they change their preference
//                // under Settings -> Privacy -> Microphone
//            }
//        }
//    }
}
