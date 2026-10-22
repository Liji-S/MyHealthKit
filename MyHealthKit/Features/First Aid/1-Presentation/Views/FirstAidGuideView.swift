import SwiftUI

struct FirstAidGuideView: View {
    @State private var viewModel: FirstAidGuideViewModel

    init(viewModel: FirstAidGuideViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.topics) { topic in
            NavigationLink {
                FirstAidTopicPlayerView(topic: topic)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: topic.systemImage)
                        .font(.title2)
                        .foregroundStyle(.red)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(topic.title).font(.headline)
                        Text(topic.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("First Aid Guide")
        .onAppear {
            viewModel.loadTopics()
        }
    }
}
