import Combine
import Foundation

public class TryNotToSmileChallenge: GenericChallengeProtocol {
    public var score: Score
    private var cancellables = Set<AnyCancellable>()
    private var smileDetector: SmileDetectorProtocol
    private lazy var myScoreSubject = PassthroughSubject<Score, Never>()
    private lazy var myIsFaceDetectedSubject = PassthroughSubject<Bool, Never>()

    // MARK: - Subjects used for communication
    public lazy var scoreSubject: AnyPublisher<Score, Never> = myScoreSubject.eraseToAnyPublisher()
    public lazy var isFaceDetected: AnyPublisher<Bool, Never> = myIsFaceDetectedSubject.eraseToAnyPublisher()

    public init(smileDetector: SmileDetectorProtocol) {
        self.smileDetector = smileDetector
        let initialScore = 100 // Now, we control the initial score in the view model
        self.score = Score(currentScore: initialScore, increment: 1, decrement: 1)

        // Observe smiles
        smileDetector
            .isSmilingSubject
            .sink(
                receiveValue: { isSmiling in
                    self.score.isSmiling = isSmiling
                    self.myScoreSubject.send(self.score)
                }
            )
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

        for cancellable in cancellables {
            cancellable.cancel()
        }
        cancellables.removeAll()
    }
}
