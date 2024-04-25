import AVFoundation
import Combine
import CoreImage
import Foundation

public protocol BlinkDetectorProtocol {
    func startBlinkDetection()
    func stopBlinkDetection()
    var isBlinkingSubject: AnyPublisher<Bool, Never> { get }
    var isFaceDetected: AnyPublisher<Bool, Never> { get }
}

public class BlinkDetector: NSObject, BlinkDetectorProtocol {
    public lazy var isBlinkingSubject = myIsBlinkingSubject.eraseToAnyPublisher()
    public lazy var isFaceDetected = myIsFaceDetectedSubject.eraseToAnyPublisher()
    private lazy var myIsBlinkingSubject = PassthroughSubject<Bool, Never>()
    private lazy var myIsFaceDetectedSubject = PassthroughSubject<Bool, Never>()

    // MARK: Challenge detection feature = [CIDetectorEyeBlink: true]
    private let detector: DetectorProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(detector: DetectorProtocol) {
        self.detector = detector

        super.init()

        self.detector
            .isDetectedFeatureSubject
            .sink { [weak self] features in
                for feature in features {
                    if feature.leftEyeClosed || feature.rightEyeClosed {
                        self?.myIsBlinkingSubject.send(true)
                    } else {
                        self?.myIsBlinkingSubject.send(false)
                    }
                }
            }
            .store(in: &cancellables) // mantem a referencia

        self.detector
            .isFaceDetected
            .removeDuplicates()
            .sink { [weak self] faceDetected in
                self?.myIsFaceDetectedSubject.send(faceDetected)
            }
            .store(in: &cancellables)
    }

    public func startBlinkDetection() {
        self.detector.startDetection()
    }

    public func stopBlinkDetection() {
        self.detector.stopDetection()
    }
}
