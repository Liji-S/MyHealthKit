import Foundation

struct FetchFirstAidTopicsUseCaseImpl: FetchFirstAidTopicsUseCaseProtocol {
    private let repository: FirstAidTopicRepositoryProtocol

    init(repository: FirstAidTopicRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> [FirstAidTopic] {
        repository.fetchAll()
    }
}
