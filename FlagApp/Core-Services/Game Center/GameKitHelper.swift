// based on code from raywenderlich.com
// helper class to make interacting with the Game Center easier
import GameKit
import UIKit

public extension GameKitHelper {
    enum Error: Swift.Error {
        case notAuthenticated
        case openAuthController
        case other
    }
}

public struct LeaderboardScore: Identifiable {
    public var id: String
    let playerName: String
    let score: Int
    let rank: Int
}

open class GameKitHelper: NSObject, ObservableObject, GKGameCenterControllerDelegate {
    @Published public var enabled: Bool = false
    public var authenticationViewController: UIViewController?
    public var lastError: Swift.Error?
    public class var sharedInstance: GameKitHelper {
        GameKitHelper._singleton
    }
    public var gameCenterEnabled: Bool {
        GKLocalPlayer.local.isAuthenticated
    }
    public var shouldRequestUserAuthentication: Bool = false

    private let leaderboardID = "rpranking"
    private var leaderboard: GKLeaderboard?
    private static let _singleton = GameKitHelper()

    override private init() {
        super.init()
    }

    public func isAuthenticated() -> Bool {
        GKLocalPlayer.local.isAuthenticated
    }

    public func authenticateLocalPlayer(completion: @escaping (Result<Bool, GameKitHelper.Error>) -> Void) {
        let localPlayer = GKLocalPlayer.local
        print("Is local player authenticated: \(localPlayer.isAuthenticated)")

        localPlayer.authenticateHandler = { viewController, error in
            if let error = error as NSError? {
                switch error.code {
                case 2:
                    print("Request was canceled by the user")

                default:
                    print("Error code = \(error.code)")
                }
                print("Error authentication ")
                print(error.localizedDescription)
                completion(.failure(.other))
            } else {
                self.lastError = error as NSError?
                self.enabled = GKLocalPlayer.local.isAuthenticated

                print("isAuthenticated = \(self.enabled)")

                if self.enabled == false {
                    print("USER IS NOT AUTHENTICATED")
                        if viewController != nil {
                            self.authenticationViewController = viewController
                            completion(.failure(.openAuthController))
                        } else {
                            completion(.failure(.notAuthenticated))
                        }
                } else {
                    completion(.success(true))
                }
                self.shouldRequestUserAuthentication = self.enabled
            }
        }
    }

    private func getPlayerinformation(from player: GKLocalPlayer ) {
        print(" ---------- Player info ----------")
        print("gamePlayerID: ", player.gamePlayerID)  // Maybe save it on firebase
        print("teamPlayerID: ", player.teamPlayerID)
        print(" ---------------------------------")
    }

    public func fetchLeaderboard(finished: @escaping () -> Void) {
            // check if local player authentificated or not
            if GKLocalPlayer.local.isAuthenticated {
                // load leaderboard from Game Center
                GKLeaderboard.loadLeaderboards { [weak self] leaderboards, error in
                    // check for errors
                    if error != nil {
                        print("Fetching leaderboard -- \(error!)")
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url, completionHandler: .none)
                        }
                    } else {
                        // if leaderboard exists
                        if leaderboards != nil {
                            for leaderboard in leaderboards! where leaderboard.identifier == self?.leaderboardID {
                                // find leaderboard with given ID (if there are multiple leaderboards)
                                self?.leaderboard = leaderboard
                                print("leaderboard ", leaderboard)
                                finished()
                            }
                        }
                    }
                }
            } else {
                print("fetchLeaderboard - local player is not authenticated")
            }
        }

    // method for loading scores from leaderboard
    public func loadScores(completion: @escaping (Result<[LeaderboardScore], Swift.Error>) -> Void) {
        // fetch leaderboard from Game Center
        fetchLeaderboard { [weak self] in
            if let localLeaderboard = self?.leaderboard {
                // set player scope as .global (it's set by default) for loading all players results
                localLeaderboard.playerScope = .global
                // load scores and then call method in closure
                localLeaderboard.loadScores { scores, error in
                    // check for errors
                    if let error = error {
                        print(error)
                        completion(.failure(error))
                    } else if let scores = scores {
                        // assemble leaderboard info
                        var leaderboardScores = [LeaderboardScore]()
                        for score in scores {
                            let teamPlayerID = score.player.teamPlayerID
                            let name = score.player.alias
                            let userScore = Int(score.value)
                            leaderboardScores.append(.init(id: teamPlayerID, playerName: name, score: userScore, rank: score.rank))
                        }
                        // call finished method
                        print("scores ---------------------------------")
                        print(scores)
                        completion(.success(leaderboardScores))
                    }
                }
            }
        }
    }

    // update local player score
    func updateScore(with value: Int) {
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score]) { error in
            if error != nil {
                print("Score updating -- \(error!)")
            }
        }
    }

    public var gameCenterViewController: GKGameCenterViewController? {
        guard gameCenterEnabled
        else {
            print("Local player is not authenticated")
            return nil
        }

        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        return gameCenterViewController
    }

    open func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

// Messages sent using the Notification Center to trigger
// Game Center's Popup screen
public enum PopupControllerMessage: String {
    case presentAuthentication = "PresentAuthenticationViewController"
    case gameCenter = "GameCenterViewController"
}

public extension PopupControllerMessage {
    func postNotification() {
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: self.rawValue),
            object: self
        )
    }

    func addHandlerForNotification(_ observer: Any, handler: Selector) {
        NotificationCenter
            .default
            .addObserver(
                observer,
                selector: handler,
                name: NSNotification.Name(rawValue: self.rawValue),
                object: nil
            )
    }
}
