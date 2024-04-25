import AuthenticationServices

public class SignInWithAppleController: NSObject {
    private var currentNonce: String?
    private var authenticationCompletion: ((Result<AuthCredential, AuthError>) -> Void)?

    // MARK: - Controller Methods
    override public init() { }

    public func authenticate(_ controller: ASAuthorizationController, nonce: String, completion: @escaping (Result<AuthCredential, AuthError>) -> Void) {
        controller.delegate = self
        controller.performRequests()
        currentNonce = nonce
        authenticationCompletion = completion
    }
}

extension SignInWithAppleController: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
            }

            let givenName = appleIDCredential.fullName?.givenName ?? ""
            let familyName = appleIDCredential.fullName?.familyName ?? ""

            let credential = AuthCredential(
                providerId: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce,
                fullName: "\(givenName) \(familyName)",
                email: appleIDCredential.email
            )
            authenticationCompletion?(.success(credential))
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authenticationCompletion?(.failure(.cancelled))
    }
}
