import Combine
import FirebaseAuth
import Foundation
import SwiftUI

public class AuthenticationManager: ObservableObject {
    @Published var userCredential: UserCredential?

    private var firebaseAuthService: FirebaseAuthService
    private var appleAuthController: AuthController = AppleSignInControllerAuthAdapter(
        controller: SignInWithAppleController(),
        nonceProvider: NonceProvider()
    )

    public init(firebaseAuthService: FirebaseAuthService) {
        self.firebaseAuthService = firebaseAuthService
    }

    public func logout() {
        self.userCredential = nil
        self.firebaseAuthService.signOut()
    }

    public func signInWithApple() -> AnyPublisher<Void, AuthError> {
        appleAuthController
            .authenticate()
            .flatMap { firebaseAuth in
                self.firebaseAuthService
                    .link(credential: firebaseAuth)
            }
            .map { firebaseUser in
                let userCredential = firebaseUser.map()
                self.userCredential = userCredential
            }
            .eraseToAnyPublisher()
    }
}

public extension AuthCredential {
    func map() -> OAuthCredential {
        OAuthProvider.credential(
            withProviderID: self.providerId,
            idToken: self.idToken,
            rawNonce: self.rawNonce
        )
    }
}
