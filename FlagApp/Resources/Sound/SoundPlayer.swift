import AVFoundation

var audioPlayer: AVAudioPlayer?

public struct Sound {
    let name: String
    let type: String

    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }
}

public func playSound(sound: Sound) {
    if let path = Bundle.main.url(forResource: sound.name, withExtension: sound.type) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer?.volume = 5
            audioPlayer?.play()
        } catch {
            print("ERROR: Could not play audio for path: \(path)")
        }
    } else {
        print("Path not found")
    }
}
