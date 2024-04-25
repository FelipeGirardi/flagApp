import Foundation

struct TrendingInfo {
    var sectionName: String
    var imageStrings: [String]
}

// MARK: Mock TrendingInfo array
var trendingInfos: [TrendingInfo] = [TrendingInfo(sectionName: "Trending music videos", imageStrings: ["MockMusicVideo1", "MockMusicVideo2"]), TrendingInfo(sectionName: "Trending audios", imageStrings: ["MockMusicVideo1", "MockMusicVideo2"]), TrendingInfo(sectionName: "MEMES!", imageStrings: ["MockMusicVideo1", "MockMusicVideo2"])]
