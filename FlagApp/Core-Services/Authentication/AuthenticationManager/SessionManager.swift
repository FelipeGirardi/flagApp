import Combine
import FirebaseAuth
import Foundation
import Resolver
import SwiftUI

public protocol SessionManagerProtocol {
}

public extension AuthCredential {
    func map() -> OAuthCredential {
        OAuthProvider.credential(withProviderID: self.providerId, idToken: self.idToken, rawNonce: self.rawNonce)
    }
}

public class AuthenticationManager: SessionManagerProtocol, ObservableObject {
    @Published var user: FlagApp.User = .init()
    public lazy var userPublisher: AnyPublisher<User, Never> = myUserSubject.eraseToAnyPublisher()

    private lazy var myUserSubject = PassthroughSubject<User, Never>()
    private var firebaseAuthService: FirebaseAuthService = Resolver.resolve()
    private var cancellables = Set<AnyCancellable>()
    private var appleAuthController: AuthController = AppleSignInControllerAuthAdapter(
        controller: SignInWithAppleController(),
        nonceProvider: NonceProvider()
    )

    public init() {
        self.appleAuthController
            .authPublisher
            .map { $0.map() }
            .flatMap { firebaseAuth in
                self.firebaseAuthService
                    .link(credential: firebaseAuth)
            }
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break

                    case .failure(.unknown):
                        print("unknown error")

                    case .failure(.userNotFound):
                        print("userNotFound error")
                    }
                },
                receiveValue: { firebaseUser in
                    self.myUserSubject.send(firebaseUser.map())
                    print("SUCESSO: \(firebaseUser)")
                }
            )
            .store(in: &cancellables)
    }

    public func logout() {
        self.firebaseAuthService.signOut()
    }

    public func signInWithApple() {
        appleAuthController
            .authenticate()
    }
}
