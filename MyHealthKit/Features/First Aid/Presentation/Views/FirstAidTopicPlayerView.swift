import AVKit
import SwiftUI

struct FirstAidTopicPlayerView: View {
    let topic: FirstAidTopic

    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: topic.videoResourceName, withExtension: "mp4") {
                VideoPlayer(player: AVPlayer(url: url))
            } else {
                ContentUnavailableView(
                    "Video Not Available",
                    systemImage: "video.slash",
                    description: Text("This demo video hasn't been added to the app yet.")
                )
            }
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
