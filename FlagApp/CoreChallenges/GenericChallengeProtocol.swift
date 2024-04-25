//
//  GenericChallengeProtocol.swift
//  FlagApp
//
//  Created by Anderson on 05/08/20.
//  Copyright © 2020 Flag. All rights reserved.
//
import Combine
import Foundation

public protocol GenericChallengeProtocol {
    func startChallenge()
    func stopChallenge()
    var scoreSubject: AnyPublisher<Score, Never> { get set }
    var isFaceDetected: AnyPublisher<Bool, Never> { get set }
}

public class Score {
    public var currentScore: Int = 1_000
    public var losePointsEffect: Bool = false

    private let increment: Int
    private let decrement: Int
    private(set) var isGameOver = false

    init(
        currentScore: Int = 0,
        increment: Int = 0,
        decrement: Int = 0
    ) {
        self.currentScore = currentScore
        self.increment = increment
        self.decrement = decrement
    }

    func decrementScore() {
        if !isGameOver {
            currentScore -= decrement
        }
    }

    func incrementScore() {
        if !isGameOver {
            currentScore += increment
        }
    }

    func getCurrentScore() -> Int {
        currentScore
    }

    func enableLosePointsEffect() {
        losePointsEffect = true
    }

    func disableLosePointsEffect() {
        losePointsEffect = false
    }

    func enableGameOver() {
        isGameOver = true
    }
}
