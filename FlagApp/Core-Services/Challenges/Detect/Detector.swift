import AVFoundation
import Combine
import CoreImage
import Foundation

public protocol DetectorProtocol {
    func startDetection()
    func stopDetection()
    var isDetectedFeatureSubject: AnyPublisher<[CIFaceFeature], Never> { get }
    var isFaceDetected: AnyPublisher<Bool, Never> { get }
}

public class Detector: NSObject, DetectorProtocol {
    public lazy var isDetectedFeatureSubject = myDetectedFeatureSubject.eraseToAnyPublisher()
    public lazy var isFaceDetected = myIsFaceDetectedSubject.eraseToAnyPublisher()
    private let sessionManager: CameraSessionManager
    private var videoDataOutput: AVCaptureVideoDataOutput
    private lazy var myDetectedFeatureSubject = PassthroughSubject<[CIFaceFeature], Never>()
    private lazy var myIsFaceDetectedSubject = PassthroughSubject<Bool, Never>()
    private lazy var faceDetector = CIDetector(
        ofType: CIDetectorTypeFace,
        context: nil,
        options: [
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        ]
    )!
    private let faceFeatureOptions: [String: Any]

    public init(sessionManager: CameraSessionManager, challengeType: ChallengeType) {
        self.sessionManager = sessionManager

        switch challengeType {
        case .TNTSmile:
            self.faceFeatureOptions = [CIDetectorSmile: true]

        case .TNTBlink:
            self.faceFeatureOptions = [CIDetectorEyeBlink: true]

        case .COMINGSOON:
            self.faceFeatureOptions = [CIDetectorSmile: true]
        }

        self.videoDataOutput = AVCaptureVideoDataOutput()

        super.init()
    }

    public func startDetection() {
        plugDetector()
    }

    public func stopDetection() {
        unplugDetector()
    }

    private func plugDetector() {
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
        let rgbOutputSettings = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCMPixelFormat_32BGRA)]

        self.videoDataOutput.videoSettings = rgbOutputSettings
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true

        if self.sessionManager.session.canAddOutput(self.videoDataOutput) {
            self.videoDataOutput.setSampleBufferDelegate(self, queue: self.sessionManager.sessionQueue)
            self.sessionManager.session.addOutput(self.videoDataOutput)
        }
    }

    private func unplugDetector() {
        sessionManager.session.stopRunning()
        sessionManager.session.removeOutput(self.videoDataOutput)
    }
}

extension Detector: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if output == videoDataOutput {
            //Convert current frame to `CIImage`
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            let attachments = CMCopyDictionaryOfAttachments(
                allocator: kCFAllocatorDefault,
                target: pixelBuffer,
                attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate)
            ) as? [CIImageOption: Any]

            let ciImage = CIImage(cvImageBuffer: pixelBuffer, options: attachments)

            //Detects faces base on your `ciImage`
            let features = faceDetector.features(
                in: ciImage,
                options: faceFeatureOptions
            )
                .compactMap({ $0 as? CIFaceFeature })

            if features.isEmpty == false {
                myDetectedFeatureSubject.send(features)
                myIsFaceDetectedSubject.send(true)
            } else {
                myIsFaceDetectedSubject.send(false)
            }
        }
    }
}
