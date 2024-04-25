import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Profile: Codable, Identifiable, Hashable {
    var serialNumber: String? // to conform Hashable protocol
    @DocumentID var id: String?
    var userId: String?
    var name: String?
    var nickname: String?
    var subtitle: String?
    var aboutMe: String?
    var cash: Int?
    var boughtFlagsIDs: [String]?
    var tags: [Tag?]
    var profileImage: Data?
    var profileSelectedFlagName: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(serialNumber)
    }
}

extension Profile {
    struct Tag: Codable, Hashable {
        var icon: String?
        var title: String?
    }
}
