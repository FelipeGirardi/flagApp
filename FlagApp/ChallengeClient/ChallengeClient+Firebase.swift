import Combine
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

public extension ChallengeClient {
    /// Provide a `ChallengeClient` implementation using `Firebase`
    static let firebaseClient = Self(
        load: { userId in
            var firestoreDB = Firestore.firestore()
            return Deferred {
                Future { completion in
                    firestoreDB
                        .collection("challengeData")
                        .whereField("userId", isEqualTo: userId)
                        .getDocuments { querySnapshot, error in
                            if let error = error {
                                return completion(.failure(error))
                            }
                            if let document = querySnapshot!.documents.first {
                                if let challenge = try? document.data(as: ChallengeData.self) {
                                    completion(.success(challenge))
                                }
                            } else {
                                completion(.failure(NSError(domain: "Challenge not fount for userId = \(userId)", code: 0)))
                            }
                        }
                }
            }
            .eraseToAnyPublisher()
        },
        save: { challenge in
            var firestoreDB = Firestore.firestore()
            return
                Future { completion in
                    firestoreDB
                        .collection("challengeData")
                        .whereField("userId", isEqualTo: challenge.userId as Any)
                        .getDocuments { querySnapshot, error in
                            if let error = error {
                                return completion(.failure(error))
                            }
                            if let document = querySnapshot!.documents.first {
                                do {
                                    try firestoreDB
                                        .collection("challengeData")
                                        .document(document.documentID)
                                        .setData(from: challenge)
                                    completion(.success(Void()))
                                } catch let error {
                                    return completion(.failure(error))
                                }
                            } else {
                                completion(.failure(NSError(domain: "Challenge not fount for userId = \(String(describing: challenge.userId))", code: 0)))
                            }
                        }
                }

            .eraseToAnyPublisher()
        }
    )
}
