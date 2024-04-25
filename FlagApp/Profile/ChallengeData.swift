import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct ChallengeData: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String?
    var totalPoints: Int?   // - MARK: check if user passed level after challenge is completed
    var level: Int?
    var numberOfAchievements: Int?

    mutating func addPoints(points: Int) {
        if let totalPoints = self.totalPoints {
            self.totalPoints = totalPoints + points
        }
    }

    func checkLevelChange(points: Int) -> Bool {
        if let level = self.level {
            if (getPointsToNextLevel(points: points) < 1) && level != 19 {
                print("Passou de nível")
                return true
            } else {
                return false
            }
        }
        return false
    }

    mutating func changeLevel() {
        if let level = self.level {
            self.level = level + 1
        }
    }

    // MARK: functions that determine how many points are left for the player to reach the next level
    func getPointsToNextLevel(points: Int) -> Int {
        if let totalPoints = self.totalPoints, let level = self.level {
            return (pointsToNextLevel * level) - ((totalPoints + points) - getTotalPointsToNextLevel(level: level - 1))
        } else {
            return 250
        }
    }

    func getTotalPointsToNextLevel(level: Int) -> Int {
        (pointsToNextLevel / 2) * Int(pow(Double(level), 2)) + ((pointsToNextLevel / 2) * level)
    }
}
