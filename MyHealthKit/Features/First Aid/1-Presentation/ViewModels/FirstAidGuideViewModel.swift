import Foundation
import Observation

@Observable
final class FirstAidGuideViewModel {
    private(set) var topics: [FirstAidTopic] = []

    private let fetchTopicsUseCase: FetchFirstAidTopicsUseCaseProtocol

    init(fetchTopicsUseCase: FetchFirstAidTopicsUseCaseProtocol) {
        self.fetchTopicsUseCase = fetchTopicsUseCase
    }

    func loadTopics() {
        topics = fetchTopicsUseCase.execute()
    }
}
