import CryptoKit
import Foundation

public struct Nonce {
    let raw: String
    let sha256: String
}

public protocol NonceProviderProtocol {
    func generateNonce() -> Nonce
}

public class NonceProvider: NonceProviderProtocol {
    public init() { }

    public func generateNonce() -> Nonce {
        let raw = randomNonceString()
        return Nonce(raw: raw, sha256: sha256(raw))
    }

    private func randomNonceString() -> String {
        let length: Int = 32
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }
        .joined()
        return hashString
    }
}
