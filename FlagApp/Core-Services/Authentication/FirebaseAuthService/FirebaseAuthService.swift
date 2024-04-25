import Combine
import FirebaseAuth
import Foundation

public class FirebaseAuthService: AuthenticationService, ObservableObject {
    @Published var user: FirebaseAuth.User?
    private var handle: AuthStateDidChangeListenerHandle?
    private let userManager: UserManager
    private var cancellables = Set<AnyCancellable>()

    public init(userManager: UserManager) {
        // replace with logOut() for testing if needed
        self.userManager = userManager
        registerStateListener()
    }

    public func signIn() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously()
        }
    }

    public func signIn(with credential: OAuthCredential) -> AnyPublisher<FirebaseAuth.User, FirebaseAuthError> {
        Deferred {
            Future { completion in
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print("Error authenticating: \(error.localizedDescription)")
                        completion(.failure(.unknown))
                    }
                    if let user = result?.user {
                        completion(.success(user))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    public func reAuthenticate(credential: OAuthCredential) -> AnyPublisher<FirebaseAuth.User, Error> {
        Deferred {
            Future { completion in
                Auth.auth().currentUser?.reauthenticate(
                    with: credential,
                    completion: { result, error in
                        if let error = error {
                            completion(.failure(error))
                        }
                        if let user = result?.user {
                            completion(.success(user))
                        }
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }

    public func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error when trying to sign out: \(error.localizedDescription)")
        }
    }

    private func registerStateListener() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }

        // next line: _ = auth
        self.handle = Auth.auth().addStateDidChangeListener { _, user in
            print("Sign in state has changed.")
            self.user = user

            if let user = user {
                if !user.isAnonymous {
                    self.userManager.loadProfile(userCredential: UserCredential(id: user.uid, isAnonymous: user.isAnonymous, email: user.email ?? "não fornecido", displayName: user.displayName ?? "não fornecido"))
                        .sink(receiveCompletion: { loadProfileCompletion in
                            switch loadProfileCompletion {
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
                            }, receiveValue: { profile in
                                // set UserDefaults: user is logged in
                                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                self.userManager.profile = profile
                            }
                        )
                    .store(in: &self.cancellables)
                }
            } else {
                self.signIn()
            }
        }
    }

    public func link(credential: AuthCredential) -> AnyPublisher<FirebaseAuth.User, AuthError> {
        Deferred {
            Future { completion in
                if let user = Auth.auth().currentUser {
                    user.link(with: credential.map()) { result, error in
                        if let error = error, (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                            if let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential {
                                Auth.auth().signIn(with: updatedCredential) { result, _ in
                                    if let resultUser = result?.user {
                                        let displayName = credential.fullName ?? "Não fornecido"
                                        self.update(for: resultUser, using: displayName) { result in
                                            switch result {
                                            case let .success(user):
                                                completion(.success(user))

                                            case .failure:
                                                completion(.success(resultUser))
                                            }
                                        }
                                    }
                                }
                            }
                        } else if error != nil {
                            completion(.failure(.unknown))
                        } else {
                            if let resultUser = result?.user {
                                let displayName = credential.fullName ?? "Não fornecido"
                                self.update(for: resultUser, using: displayName) { result in
                                    switch result {
                                    case let .success(user):
                                        completion(.success(user))

                                    case .failure:
                                        completion(.success(resultUser))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func update(
        for user: FirebaseAuth.User,
        using name: String,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let updatedUser = Auth.auth().currentUser {
                    self.user = updatedUser
                    completion(.success(user))
                }
            }
        }
    }
}

public extension FirebaseAuthService {
    enum FirebaseAuthError: Error {
        case userNotFound
        case userAlreadyBeenLinked(OAuthCredential)
        case unknown
    }
}

public extension FirebaseAuth.User {
    func map() -> UserCredential {
        UserCredential(
            id: self.uid,
            isAnonymous: self.isAnonymous,
            email: self.email ?? "Não fornecido",
            displayName: self.displayName ?? "Não fornecido"
        )
    }
}
