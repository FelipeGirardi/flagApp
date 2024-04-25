//
//  TrynotToBlinkChallenge.swift
//  FlagApp
//
//  Created by Anderson on 09/08/20.
//  Copyright © 2020 Flag. All rights reserved.
//
import Combine
import Foundation

public class TryNotToBlinkChallenge: GenericChallengeProtocol {
    // MARK: - Subjects used for outside communication
    public lazy var scoreSubject: AnyPublisher<Score, Never> = myScoreSubject.eraseToAnyPublisher()
    public lazy var isFaceDetected: AnyPublisher<Bool, Never> = myIsFaceDetectedSubject.eraseToAnyPublisher()

    private let blinkDetector: BlinkDetectorProtocol
    private var cancellables = Set<AnyCancellable>()
    private lazy var myScoreSubject = PassthroughSubject<Score, Never>()
    private lazy var myIsFaceDetectedSubject = PassthroughSubject<Bool, Never>()
    private var score: Score = Score(currentScore: 50, increment: 1, decrement: 1)

    public init(
        blinkDetector: BlinkDetectorProtocol
    ) {
        self.blinkDetector = blinkDetector

        blinkDetector
            .isBlinkingSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] isBlinking in
                guard let self = self
                else {
                    return
                }
                if self.score.currentScore <= 0 {
                     self.score.enableGameOver()
                }
                if isBlinking {
                    self.score.enableLosePointsEffect()
                    self.score.decrementScore()
                } else {
                    self.score.disableLosePointsEffect()
                }
                self.myScoreSubject.send(self.score)
            }
            .store(in: &cancellables)

        blinkDetector
            .isFaceDetected
            .sink { [weak self] isFaceDetected in
                self?.myIsFaceDetectedSubject.send(isFaceDetected)
            }
            .store(in: &cancellables)
    }

    public func startChallenge() {
        blinkDetector.startBlinkDetection()
    }

    public func stopChallenge() {
        blinkDetector.stopBlinkDetection()
    }
}
