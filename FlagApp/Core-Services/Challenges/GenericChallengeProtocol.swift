import Combine
import Foundation

public protocol GenericChallengeProtocol {
    func startChallenge()
    func stopChallenge()
    var scoreSubject: AnyPublisher<Score, Never> { get set }
    var isFaceDetected: AnyPublisher<Bool, Never> { get set }
}

public class Score {
    public var currentScore: Int
    public var losePointsEffect: Bool = false
    public var isSmiling = false
    public private(set) var isGameOver = false

    private let increment: Int
    private let decrement: Int

    public init(
        currentScore: Int = 0,
        increment: Int = 0,
        decrement: Int = 0
    ) {
        self.currentScore = currentScore
        self.increment = increment
        self.decrement = decrement
    }

    func decrementScore() {
        if !isGameOver && currentScore > 0 {
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

public struct ChallengeInfo: Hashable {
    public var challengeName: String
    public var challengeShortDescription: String
    public var challengeFullDescription: String
    public var challengeImageString: String
    public var challengeBackgroundImageName: String
    public var challengeHowToPlayDescription: String
    public var challengeType: ChallengeType
    public var challengeVideoIDs: [String]

    public init(
        challengeName: String,
        challengeShortDescription: String,
        challengeFullDescription: String,
        challengeImageString: String,
        challengeBackgroundImageName: String,
        challengeHowToPlayDescription: String,
        challengeType: ChallengeType,
        challengeVideoIDs: [String]
    ) {
        self.challengeName = challengeName
        self.challengeShortDescription = challengeShortDescription
        self.challengeFullDescription = challengeFullDescription
        self.challengeImageString = challengeImageString
        self.challengeBackgroundImageName = challengeBackgroundImageName
        self.challengeHowToPlayDescription = challengeHowToPlayDescription
        self.challengeType = challengeType
        self.challengeVideoIDs = challengeVideoIDs
    }
}

public enum ChallengeType {
    case TNTSmile
    case TNTBlink
    case COMINGSOON
}
