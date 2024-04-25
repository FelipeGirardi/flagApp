import Combine
import Foundation
import SwiftUI

public final class SignInViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var challengeData: ChallengeData?
    @Published var isLogginOut = false
    @Published var doingSignIn = true
    @Published var points: Int = 0
    @ObservedObject var userManager: UserManager

    private var appleAuthController: AuthController
    private var cancellables = Set<AnyCancellable>()
    private var sessionManager: AuthenticationManager

    // swiftlint:disable:next function_body_length
    public init(
        appleAuthController: AuthController,
        userManager: UserManager,
        sessionManager: AuthenticationManager
    ) {
        self.appleAuthController = appleAuthController
        self.userManager = userManager
        self.sessionManager = sessionManager

        // This pipeline is responsable for observing any changes to profile.
        sessionManager
            .$userCredential
            .sink( receiveValue: { credential in
                guard let credential = credential
                    else {
                        return
                    }
                    self.userManager
                        .loadProfile(userCredential: credential)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break

                            case let .failure(error):
                                switch error {
                                case .profileNotFound:
                                    self.doingSignIn = false

                                case .unknown:
                                    self.doingSignIn = false
                                }
                            }
                            }, receiveValue: { profile in
                                // Received a profile. It could be received from sign in with Apple.
                                self.profile = profile
                                self.doingSignIn = false
                            }
                        )
                        .store(in: &self.cancellables)
                }
            )
            .store(in: &cancellables)

        // Observe changes to profile
        userManager
            .$profile
            .sink(receiveValue: { profile in
                if profile == nil {
                    let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
                    if !isLoggedIn {
                        self.doingSignIn = false
                    }
                    // Set profile viewmModel to nil because there is not profile logged 
                    self.profile = nil
                } else {
                    // Receive profile from userManager
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self.profile = profile
                        self.doingSignIn = false
                    }
                }
            }
            )
            .store(in: &cancellables)

        // Here we observe changes to challengeData
        userManager
            .$challengeData
            .sink { challengeData in
                DispatchQueue.main.async {
                    self.challengeData = challengeData
                }
            }
        .store(in: &self.cancellables)
    }

    func updateProfile(newProfileData: Profile, mustRemoveImage: Bool) {
        self.userManager
            .updateProfileData(newProfileData: newProfileData, mustRemoveImage: mustRemoveImage)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break

                case let .failure(error):
                    switch error {
                    case .profileNotFound:
                        print("Error: profileNotFound")

                    case .unknown:
                        print("Error: unknown")
                    }
                }
                }, receiveValue: { _ in
                    print("Profile updated")
                }
            )
            .store(in: &self.cancellables)
    }

    public func logout() {
        self.sessionManager.logout()
        userManager.profile = nil
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        isLogginOut = false
        self.doingSignIn = false
    }

    public func signInWithApple() {
        self.doingSignIn = true
        sessionManager
            .signInWithApple()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break

                    case .failure:
                        self.doingSignIn = false
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
