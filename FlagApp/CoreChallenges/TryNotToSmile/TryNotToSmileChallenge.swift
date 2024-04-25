//
//  TryNotSmile.swift
//  FlagApp
//
//  Created by Anderson on 28/07/20.
//  Copyright © 2020 Flag. All rights reserved.
//
import Combine
import Foundation

public class TryNotToSmileChallenge: GenericChallengeProtocol {
    private var cancellables = Set<AnyCancellable>()
    private var smileDetector: SmileDetectorProtocol
    private var type: ChallengeType = .regular
    private lazy var myScoreSubject = PassthroughSubject<Score, Never>()
    private var score: Score = Score(currentScore: 50, increment: 1, decrement: 1)
    private lazy var myIsFaceDetectedSubject = PassthroughSubject<Bool, Never>()

    // MARK: - Subjects used for communication
    public lazy var scoreSubject: AnyPublisher<Score, Never> = myScoreSubject.eraseToAnyPublisher()
    public lazy var isFaceDetected: AnyPublisher<Bool, Never> = myIsFaceDetectedSubject.eraseToAnyPublisher()

    public init(smileDetector: SmileDetectorProtocol) {
        self.smileDetector = smileDetector

        smileDetector
            .isSmilingSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] isSmiling in
                guard let self = self
                else {
                    return
                }
                if self.score.currentScore <= 0 {
                     self.score.enableGameOver()
                }
                if isSmiling {
                    self.score.enableLosePointsEffect()
                    self.score.decrementScore()
                } else {
                    self.score.disableLosePointsEffect()
                }
                self.myScoreSubject.send(self.score)
            }
            .store(in: &cancellables)

        smileDetector
            .isFaceDetected
            .sink { [weak self] isFaceDetected in
                self?.myIsFaceDetectedSubject.send(isFaceDetected)
            }
            .store(in: &cancellables)
    }

    public func startChallenge() {
        smileDetector.startSmileDetection()
    }

    public func stopChallenge() {
        smileDetector.stopSmileDetection()
    }
}

public extension TryNotToSmileChallenge {
    enum ChallengeType {
        case short
        case regular
        case long
    }
}
