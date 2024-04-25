import Foundation

public struct AuthCredential {
    var providerId: String
    var idToken: String
    var rawNonce: String
    var fullName: String?
    var email: String?
}
