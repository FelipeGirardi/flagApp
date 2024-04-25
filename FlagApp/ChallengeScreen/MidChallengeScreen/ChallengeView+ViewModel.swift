import AVFoundation
import Combine
import Foundation
import SwiftUI

public protocol ChallengeViewModelProtocol {
    // MARK: - View -> ViewModel
    func start()
    func stop()
}

public extension ChallengeView {
    final class ViewModel: ObservableObject, ChallengeViewModelProtocol {
        private static let updateTime = 0.5
        private static let mininumSecondsToEnableLosePoint = 3.0
        private var cancellables = Set<AnyCancellable>()
        private var challenge: GenericChallengeProtocol
        private let timer = Timer.publish(every: updateTime, on: .main, in: .default).autoconnect()
        private var isSmiling = false
        private var spentSecondsWithoutDetectedFace = 0.0
        private var timeObserverToken: Any?
        var audioPlayer: AVPlayer?

        let session: CameraSessionManager
        let challengeInfo: ChallengeInfo

        // MARK: - Used to communicate with view
        @Published var currentScorePoints = 100
        @Published var isVideoFinished = false
        @Published var isGameOverScreenActive = false
        @Published var videoLengthPercentage: Int = 0
        @Published var videoLengthInSeconds: Double = 0.0
        @Published var currentVideoTime: Double = 0.0
        @Published var isGameSuccessScreenActive = false
        @Published var losePointsEffect = false
        @Published var isExitingChallenge = false
        @Published var isFaceDetected = false
        @Published var enablePulsingPlaceholder = false

        public init(
            session: CameraSessionManager,
            challenge: GenericChallengeProtocol,
            challengeInfo: ChallengeInfo
        ) {
            switch challengeInfo.challengeType {
            case .TNTSmile:
                currentScorePoints = 100

            case .TNTBlink:
                currentScorePoints = 100

            case .COMINGSOON:
                currentScorePoints = 0
            }

            self.session = session
            self.challenge = challenge
            self.challengeInfo = challengeInfo

            // Subscribe to scoreSubject publisher from tntSmileChallenge
            self.challenge
                .scoreSubject
                .receive(on: RunLoop.main)
                .sink { [weak self] score in
                    guard let self = self
                        else {
                            return
                        }
                    self.isSmiling = score.isSmiling
                }
                .store(in: &cancellables)

            // MARK: - Face detection future code
            self.challenge
                .isFaceDetected
                .receive(on: RunLoop.main)
                .sink { isFaceDetected in
                    self.isFaceDetected = isFaceDetected
                }
                .store(in: &cancellables)

            self.$isVideoFinished
                .sink { [weak self] finished in
                    guard let self = self
                        else {
                            return
                        }
                    if finished {
                        self.videoLengthPercentage = 100
                        if self.currentScorePoints <= 0 {
                            self.isGameOverScreenActive = true
                        } else {
                            //userManager.challengeData.updateTotalPoints(points: self.currentScorePoints)
                            self.isGameSuccessScreenActive = true
                        }
                        self.stop()
                    }
                }
                .store(in: &cancellables)
        }

        public func start() {
            challenge.startChallenge()
            session.checkAuthorizationStatus()
            session.configureSession()
            session.startSession()

            timer
                .sink { [weak self] _ in
                    guard let self = self
                    else {
                        return
                    }
                    if self.currentScorePoints <= 0 {
                        self.stop()
                        self.isGameOverScreenActive = true
                    }

                    if self.isFaceDetected == false {
                        self.spentSecondsWithoutDetectedFace += ChallengeView.ViewModel.updateTime
                        if self.spentSecondsWithoutDetectedFace >= ChallengeView.ViewModel.mininumSecondsToEnableLosePoint {
                            self.enablePulsingPlaceholder = true
                            self.losePointsEffect = true
                            self.currentScorePoints -= 5
                        }
                    } else {
                        self.enablePulsingPlaceholder = false
                        self.spentSecondsWithoutDetectedFace = 0

                        if self.isSmiling && self.currentScorePoints >= 1 {
                            self.losePointsEffect = true
                            self.currentScorePoints -= 5
                        } else {
                            self.losePointsEffect = false
                        }
                    }
                }
                .store(in: &cancellables)
        }

        public func stop() {
            for cancellable in cancellables {
                cancellable.cancel()
            }
            cancellables.removeAll()
            self.timer.upstream.connect().cancel()
            challenge.stopChallenge()
        }

        public func getVideoLengthPercentage() -> String {
            String(self.videoLengthPercentage)
        }
    }
}
