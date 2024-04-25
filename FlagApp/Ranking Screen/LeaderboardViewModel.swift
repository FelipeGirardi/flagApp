import Combine
import Foundation

class LeaderboardViewModel: ObservableObject {
    @Published var isUserAuthenticated = false
    @Published var leaderboardScores = [LeaderboardScore]()

    private var cancellables = Set<AnyCancellable>()

    init() {
        $isUserAuthenticated
            .sink { [weak self] isAuthenticateSuccess in
                if isAuthenticateSuccess {
                    self?.getScores { }
                }
            }
            .store(in: &cancellables)
    }

    func getLeaderboard(completion: @escaping () -> Void) {
        GameKitHelper.sharedInstance.authenticateLocalPlayer { result in
            switch result {
            case .failure(.notAuthenticated):
                print("notAuthenticated")
                completion()

            case .failure(.openAuthController):
                print("openAuthController")
                PopupControllerMessage
                    .presentAuthentication
                    .postNotification()
                completion()

            case .failure(.other):
                print("Other failure")
                completion()

            case let .success(isSuccess):
                print("is sucess: \(isSuccess)")
                if isSuccess {
                    self.isUserAuthenticated = true
                    completion()
                    //GameKitHelper.sharedInstance.fetchLeaderboard { }
                }
            }
        }

        if GameKitHelper.sharedInstance.isAuthenticated() == false {
            self.isUserAuthenticated = false
        } else {
            self.isUserAuthenticated = true
        }
    }

    func authGameCenter() {
        if GameKitHelper.sharedInstance.isAuthenticated() == false {
            PopupControllerMessage
                .presentAuthentication
                .postNotification()
        } else {
            self.isUserAuthenticated = true
        }
    }

    func showLeaderboardViewController() {
        PopupControllerMessage
            .gameCenter
            .postNotification()
        getScores { }
    }

    func getScores(completion: @escaping () -> Void) {
        GameKitHelper.sharedInstance.loadScores { scores in
            switch scores {
            case let .success(leaderboardScores):
                print("Scores:")
                print(leaderboardScores)
                self.leaderboardScores = leaderboardScores
                completion()

            case let .failure(error):
                print("error: \(error)")
                completion()
            }
        }
    }
}
