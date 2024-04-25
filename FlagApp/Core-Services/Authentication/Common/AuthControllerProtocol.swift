import Combine
import Foundation

public protocol AuthController {
    func authenticate() -> AnyPublisher<AuthCredential, AuthError>
}

public enum AuthError: Error {
    case cancelled
    case userNotFound
    case unknown
}
