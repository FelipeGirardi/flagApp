import Combine
import SwiftUI
import youtube_ios_player_helper

/// A wrapper for a YoutubePlayerView view that you use to integrate that view into your SwiftUI view hierarchy.
struct YoutubePlayerView: UIViewRepresentable {
    typealias UIViewType = YTPlayerView

    var videoID: String
    var playerView = YTPlayerView()
    @Binding var isVideoEnded: Bool
    @Binding var videoLengthPercentage: Int
    @Binding var videoLengthInSeconds: Double
    @Binding var currentVideoTime: Double

    func makeUIView(context: Context) -> YTPlayerView {
        playerView.load(
            withVideoId: videoID,
            // infos about each parameter for "plaverVars" are here: https://developers.google.com/youtube/player_parameters
            // playlist: play playlist with array of ID's?
            playerVars: ["playsinline": 1, "controls": 0, "rel": 0, "end": 60]
        )
        playerView.delegate = context.coordinator
        return playerView
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {
        // We must implement this function, for now do nothing
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: Coordinator Class
    class Coordinator: NSObject, YTPlayerViewDelegate {
        var player: YoutubePlayerView
        var videoLength: Double
        var cancellables = Set<AnyCancellable>()

        init(_ youtubePlayerView: YoutubePlayerView) {
            self.player = youtubePlayerView
            self.videoLength = 0

            NotificationCenter
                .default
                .publisher(for: UIApplication.willResignActiveNotification)
                    .sink(receiveValue: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            youtubePlayerView.playerView.pauseVideo()
                        }
                    }
                )
                .store(in: &cancellables)

            NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
                .sink(receiveValue: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        youtubePlayerView.playerView.playVideo()
                    }
                }
            )
            .store(in: &cancellables)
        }

        // MARK: - YTPlayerViewDelegate
        func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
            switch state {
            case .ended:
                self.player.isVideoEnded = true

            default:
                break
            }
        }

        func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
            playerView.playVideo()
        }

        func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
            playerView.duration({ result, error in
                if error != nil {
                    self.videoLength = 0
                }
                if result < 60 { // if video length is < 1 min, make the video duration as progress complete value
                    self.videoLength = result
                } else { // else, video will play from beginning for a fixed 1 min duration and progress complete value will be 60
                    self.videoLength = 60
                }
                self.player.videoLengthInSeconds = Double(self.videoLength)
                playerView.currentTime({ currentTime, error in
                    if error != nil {
                        self.player.currentVideoTime = 0
                    } else {
                        self.player.currentVideoTime = Double(currentTime)
                    }
                }
                )
                withAnimation(.easeInOut(duration: 0.12)) {
                    let percentage = Int( (Double(playTime) / Double((self.videoLength)) ) * 100 )
                    let remaining = percentage % 5
                    if remaining == 0 {
                        // Update percentage on every 5% ammount
                        self.player.videoLengthPercentage = percentage
                    }
                }
            }
            )
        }
    }
}
