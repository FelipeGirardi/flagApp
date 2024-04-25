import Combine
import Foundation

public class UserManager: ObservableObject {
    @Published var profile: Profile?
    @Published var challengeData: ChallengeData = .init()
    //@Published var doingSignIn: Bool = true

    private let profileAPI: ProfileAPI
    private let challengeClient: ChallengeClient
    private var cancellables = Set<AnyCancellable>()

    public init(
        profileAPI: ProfileAPI = ProfileAPI(),
        challengeClient: ChallengeClient = .firebaseClient
    ) {
        self.profileAPI = profileAPI
        self.challengeClient = challengeClient

        // Every change made into challengeData is saved using ChallengeClient
        self.$challengeData
            .sink { [weak self] newChallengeData in
                guard let self = self
                    else { return }

                var mutatedChallenge = newChallengeData
                if let userID = self.profile?.userId {
                    mutatedChallenge.userId = userID
                    _ = challengeClient.save(mutatedChallenge)
                }
                if let totalPoints = mutatedChallenge.totalPoints {
                    GameKitHelper.sharedInstance.updateScore(with: totalPoints)
                }
            }
            .store(in: &cancellables)
    }

    func loadProfile(userCredential: UserCredential) -> AnyPublisher<Profile, ProfileError> {
        Deferred {
            Future { completion in
                self.profileAPI
                    .loadData(userId: userCredential.id)
                    .sink(
                        receiveCompletion: { loadCompletion in
                            switch loadCompletion {
                            case .finished:
                                break

                            case let .failure(error):
                                switch error {
                                case .profileNotFound:
                                    self.profileAPI
                                        .createProfile(
                                            userId: userCredential.id,
                                            name: userCredential.displayName
                                        )
                                        .sink(
                                            receiveCompletion: { createProfileCompletion in
                                                switch createProfileCompletion {
                                                case .finished:
                                                    break

                                                case .failure:
                                                    completion(.failure(.unknown))
                                                }
                                            },
                                            receiveValue: { profile in
                                                // MARK: save profile to userManager when creating profile (don't delete this line)
                                                self.profile = profile
                                                completion(.success(profile))
                                            }
                                        )
                                        .store(in: &self.cancellables)

                                case .unknown:
                                    break
                                }
                            }
                        },
                        receiveValue: { [weak self] profile in
                            guard let self = self else {
                                return
                            }
                            self.challengeClient
                                .load(profile.userId ?? "")
                                .replaceError(with: .init())
                                .assign(to: \.challengeData, on: self)
                                .store(in: &self.cancellables)
                            if let currentScore = self.challengeData.totalPoints {
                                GameKitHelper.sharedInstance.updateScore(with: currentScore)
                            }
                            completion(.success(profile))
                        }
                    )
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }

    func updateProfileData(newProfileData: Profile, mustRemoveImage: Bool) -> AnyPublisher<Profile, ProfileError> {
        Deferred {
            Future { completion in
                self.profileAPI
                    .saveProfileData(
                        userId: newProfileData.userId ?? "",
                        newProfileData: newProfileData,
                        mustRemoveImage: mustRemoveImage
                    )
                    .sink(
                        receiveCompletion: { updateProfileCompletion in
                            switch updateProfileCompletion {
                            case .finished:
                                break

                            case .failure:
                                completion(.failure(.unknown))
                            }
                        }, receiveValue: { profile in
                            self.profile = profile
                            completion(.success(profile))
                        }
                    )
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }

    func updateCash(withValue: Int) {
        let newCashAmount: Int = (self.profile?.cash ?? 0) + withValue
        self.profileAPI
            .saveCash(
                userID: self.profile?.userId ?? "",
                newTotalCash: newCashAmount
            )
            .sink(
                receiveCompletion: { updateCashCompletion in
                    switch updateCashCompletion {
                    case .finished:
                        break

                    case .failure:
                        print("Error updating cash")
                    }
                }, receiveValue: { _ in
                    self.profile?.cash = newCashAmount
                }
            )
            .store(in: &self.cancellables)
    }

    func buyFlag(newFlagID: String, selectedFlagName: String) -> AnyPublisher<Void, BuyFlagError> {
        guard let userId = self.profile?.userId else {
            return Fail(error: BuyFlagError.profileNotFound).eraseToAnyPublisher()
        }

        var boughtFlagsIDs: [String] = []
        if let flags = self.profile?.boughtFlagsIDs {
            boughtFlagsIDs = flags
            boughtFlagsIDs.append(newFlagID)
        } else {
            boughtFlagsIDs = [newFlagID]
        }

        return Future { [weak self] completion in
            guard let self = self
                else {
                    return
            }
            self.profileAPI
                .saveBoughtFlagsIDsArray(
                    userID: userId,
                    newBoughtFlagsIDsArray: boughtFlagsIDs,
                    selectedFlagName: selectedFlagName
                )
                .sink(
                    receiveCompletion: { updateCashCompletion in
                        switch updateCashCompletion {
                        case .finished:
                            break

                        case .failure:
                            print("Error updating cash")
                            completion(.failure(.updateCash))
                        }
                    }, receiveValue: { _ in
                        self.profile?.boughtFlagsIDs = boughtFlagsIDs
                        completion(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }

    func selectFlag(selectedFlagName: String) -> AnyPublisher<Void, BuyFlagError> {
        guard let userId = self.profile?.userId else {
            return Fail(error: BuyFlagError.profileNotFound).eraseToAnyPublisher()
        }

        return Future { [weak self] completion in
            guard let self = self
                else {
                    return
            }
            self.profileAPI
                .saveSelectedFlag(
                    userID: userId,
                    selectedFlagName: selectedFlagName
                )
                .sink(
                    receiveCompletion: { updateCashCompletion in
                        switch updateCashCompletion {
                        case .finished:
                            break

                        case .failure:
                            print("Error updating cash")
                            completion(.failure(.updateCash))
                        }
                    }, receiveValue: { _ in
                        completion(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}

enum ProfileError: Error {
    case profileNotFound
    case unknown
}

enum BuyFlagError: Error {
    case profileNotFound
    case unknown
    case updateCash
}
