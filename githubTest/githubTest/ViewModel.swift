import Foundation
import Combine

final class ViewModel: ObservableObject {
    // MARK: Public Properties
    @Published
    var searchText = ""

    @Published
    private(set) var items = [RepositoryItem]()
    
    // MARK: Private Properties
    private let dataService: DataServiceProtocol
    
    private var currentTask: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life cycle
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard !value.isEmpty else {
                    self?.items = [RepositoryItem]()
                    return
                }
                
                self?.loadData(with: value)
            }
            .store(in: &cancellables)
    }
}

// MARK: Public Methods
extension ViewModel {
    func loadData(with keyword: String) {
        currentTask?.cancel()
        currentTask = nil
        
        currentTask = dataService.requestData(with: keyword)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    switch result {
                    case .finished: break
                    case .failure(let error): break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.items = response.items
                }
            )
    }
}
