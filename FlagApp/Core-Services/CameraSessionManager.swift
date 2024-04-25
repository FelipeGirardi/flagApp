//
//  CameraSessionManager.swift
//  FlagApp
//
//  Created by Anderson on 23/07/20.
//  Copyright © 2020 Flag. All rights reserved.
//

import AVFoundation
import Combine
import CoreImage
import Foundation
import ImageIO

/// This class will manage the camera session allowing it to be shared between multiple modules and features.
public class CameraSessionManager: NSObject {
    private lazy var myStartCameraSubject = PassthroughSubject<Void, Never>()
    lazy var startCameraSubject = myStartCameraSubject.eraseToAnyPublisher()

    // This session must be shared between AR
    let session = AVCaptureSession()
    var setupResult: SessionSetupResult = .success
    var isSessionRunning = false
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!

    // Communicate with the session and other session objects on this queue.
    let sessionQueue = DispatchQueue(label: "session queue")

    func checkAuthorizationStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break

        case .notDetermined:
            sessionQueue.suspend()

            // Maybe refactor it when to use bindings with swiftUI
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
                }
            )

        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
    }

    // Call this on the session queue.
    /// - Tag: ConfigureSession
    func configureSession() {
        // swiftlint:disable closure_body_length
        sessionQueue.async {
            [weak self] in
            guard let self = self else {
                return
            }

            if self.setupResult != .success {
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // Add video input.
            do {
                var defaultVideoDevice: AVCaptureDevice?

                if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
                guard let videoDevice = defaultVideoDevice else {
                    // print("Default video device is unavailable.")
                    self.setupResult = .configurationFailed
                    self.session.commitConfiguration()
                    return
                }
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

                if self.session.canAddInput(videoDeviceInput) {
                    self.session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                    self.myStartCameraSubject.send()
                } else {
                     //print("Couldn't add video device input to the session.")
                    self.setupResult = .configurationFailed
                    self.session.commitConfiguration()
                    return
                }
            } catch {
                self.setupResult = .configurationFailed
                self.session.commitConfiguration()
                return
            }

            // Add an audio input device.
            do {
                let audioDevice = AVCaptureDevice.default(for: .audio)
                let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)

                if self.session.canAddInput(audioDeviceInput) {
                    self.session.addInput(audioDeviceInput)
                } else {
                    print("Could not add audio device input to the session")
                }
            } catch {
                print("Could not create audio device input: \(error)")
            }
            self.session.commitConfiguration()
        }
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session if setup succeeded.
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning

            case .notAuthorized:
                break

            case .configurationFailed:
                // Inform view using combine publisher???
                break
            }
        }
    }

    /// Public function that starts the session
    func start() {
        checkAuthorizationStatus()
        configureSession()
        startSession()
    }

    public enum StartSessionError: Error {
        case notAuthorized
        case configurationFailed
    }
}

public extension CameraSessionManager {
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
}
