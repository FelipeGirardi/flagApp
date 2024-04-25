import AuthenticationServices
import Combine
import Foundation

public class AppleSignInControllerAuthAdapter: AuthController {
    private let controller: SignInWithAppleController
    private let nonceProvider: NonceProviderProtocol

    public init(
        controller: SignInWithAppleController,
        nonceProvider: NonceProviderProtocol
    ) {
        self.controller = controller
        self.nonceProvider = nonceProvider
    }

    public func authenticate() -> AnyPublisher<AuthCredential, AuthError> {
        let nonce = nonceProvider.generateNonce()
        let request = makeRequest(nonce: nonce.sha256)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        return Deferred {
            Future { completion in
                self.controller
                    .authenticate(authorizationController, nonce: nonce.raw, completion: { result in
                        switch result {
                        case .failure:
                            completion(.failure(.unknown))

                        case let .success(credential):
                            completion(.success(credential))
                        }
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }

    private func makeRequest(nonce: String) -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = nonce
        return request
    }
}
