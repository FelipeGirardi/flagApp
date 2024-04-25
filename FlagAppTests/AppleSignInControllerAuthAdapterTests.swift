import AuthenticationServices
@testable import FlagApp
import XCTest

class AppleSignInControllerAuthAdapterTests: XCTestCase {
    func test_adapter_performProperRequest() {
        let controller = AppleSignInControllerSpy()
        let nonceProvider = ConstantNonceProvider()
        let nonce = nonceProvider.generateNonce()
        let sut = AppleSignInControllerAuthAdapter(controller: controller, nonceProvider: nonceProvider)

        sut.authenticate()

        XCTAssertEqual(controller.requests.count, 1, "request count")
        XCTAssertEqual(controller.requests.first?.requestedScopes, [.fullName, .email])
        XCTAssertEqual(controller.requests.first?.nonce, nonce.sha256)
    }

    private class AppleSignInControllerSpy: SignInWithAppleController {
        var requests = [ASAuthorizationAppleIDRequest]()

        override func authenticate(_ controller: ASAuthorizationController, nonce: String) {
            requests += controller.authorizationRequests.compactMap {
                $0 as? ASAuthorizationAppleIDRequest
            }
        }
    }
}

private class ConstantNonceProvider: NonceProviderProtocol {
    func generateNonce() -> Nonce {
        Nonce(raw: "a generated nonce", sha256: "a sha256 nonce")
    }
}
