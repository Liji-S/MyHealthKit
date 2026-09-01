import Foundation

@MainActor
final class FirstAidContainer {
    private lazy var topicRepository: FirstAidTopicRepositoryProtocol = StaticFirstAidTopicRepository()

    private lazy var fetchTopicsUseCase: FetchFirstAidTopicsUseCaseProtocol = FetchFirstAidTopicsUseCaseImpl(
        repository: topicRepository
    )

    func makeFirstAidGuideViewModel() -> FirstAidGuideViewModel {
        FirstAidGuideViewModel(fetchTopicsUseCase: fetchTopicsUseCase)
    }
}
