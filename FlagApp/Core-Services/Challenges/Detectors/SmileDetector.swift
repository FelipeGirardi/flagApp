//
//  SmileDetector.swift
//  FlagApp
//
//  Created by Anderson on 27/07/20.
//  Copyright © 2020 Flag. All rights reserved.
//
import Combine
import Foundation

public protocol SmileDetectorProtocol {
    func startSmileDetection()
    func stopSmileDetection()
    var isSmilingSubject: AnyPublisher<Bool, Never> { get }
    var isFaceDetected: AnyPublisher<Bool, Never> { get }
}

public class SmileDetector: NSObject, SmileDetectorProtocol {
    public lazy var isSmilingSubject = myIsSmilingSubject.eraseToAnyPublisher()
    public lazy var isFaceDetected = myIsFaceDetectedSubject.eraseToAnyPublisher()
    private lazy var myIsSmilingSubject = PassthroughSubject<Bool, Never>()
    private lazy var myIsFaceDetectedSubject = PassthroughSubject<Bool, Never>()

    // MARK: Challenge detection feature = [CIDetectorSmile: true]
    private let detector: DetectorProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(detector: DetectorProtocol) {
        self.detector = detector

        super.init()

        self.detector
            .isDetectedFeatureSubject
            .sink { features in
                for feature in features {
                    if feature.hasSmile {
                        self.myIsSmilingSubject.send(true)
                    } else {
                        self.myIsSmilingSubject.send(false)
                    }
                }
            }
            .store(in: &cancellables) // mantem a referencia

        self.detector
            .isFaceDetected
            .sink { faceDetected in
                self.myIsFaceDetectedSubject.send(faceDetected)
            }
            .store(in: &cancellables)
    }

    public func startSmileDetection() {
        self.detector.startDetection()
    }

    public func stopSmileDetection() {
        self.detector.stopDetection()
    }
}
