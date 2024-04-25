import Combine
import Foundation

/// This struct have all  the functions variables that every client must provide. It  replaces  the usage of a protocol
public struct ChallengeClient {
    /// Loads `ChallengeData` given an `userId`.
    ///
    /// @param userId: The id of the user that owns a `ChallengeData`
    ///
    /// @return: `AnyPublisher` with a `ChallengeData` if success or  `Error` if failure.
    var load: (_ userId: String) -> AnyPublisher<ChallengeData, Error>

    /// Saves a `ChallengeData`
    ///
    /// @param challenge: A `ChallengeData` that should be saved.
    ///
    /// @return: `AnyPublisher` with a `Void` if success or  `Error` if failure.
    var save: (_ challenge: ChallengeData) -> AnyPublisher<Void, Error>
}
