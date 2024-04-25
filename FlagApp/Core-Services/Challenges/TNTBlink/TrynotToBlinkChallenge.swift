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
    public var score: Score = Score(currentScore: 100, increment: 1, decrement: 1)

    public init(
        blinkDetector: BlinkDetectorProtocol
    ) {
        self.blinkDetector = blinkDetector

        blinkDetector
            .isBlinkingSubject
            .sink { [weak self] isBlinking in
                guard let self = self
                else {
                    return
                }
                if self.score.currentScore <= 0 {
                     self.score.enableGameOver()
                }
                // TODO: FIX IT 
                self.score.isSmiling = isBlinking
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
