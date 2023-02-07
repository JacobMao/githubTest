import Foundation
import SwiftUI
import Combine

final class ViewModel: ObservableObject {
    enum Design {
        enum SearchView {
            static let padding = EdgeInsets(
                top: 8,
                leading: 8,
                bottom: 0,
                trailing: 8
            )
            
            static let font = Font.system(size: 20)
        }
    }
    
    // MARK: Public Properties
    @Published var searchText = ""

    @Published private(set) var items = [RepositoryItem]()
    
    @Published var presentAlert = false
    private(set) var latestError: Error?
    
    let errorTitle = Text("Error")
    
    // MARK: Private Properties
    private let dataService: DataServiceProtocol
    
    private var currentTask: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var latestSearchText = ""
    
    // MARK: Life cycle
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        
        $searchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let strongSelf = self else {
                    return
                }
                
                guard value != strongSelf.latestSearchText else {
                    return
                }
                
                strongSelf.latestSearchText = value
                
                guard !value.isEmpty else {
                    strongSelf.items = [RepositoryItem]()
                    return
                }
                
                strongSelf.loadData(with: value)
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
                receiveCompletion: { [weak self] result in
                    switch result {
                    case .finished: break
                    case .failure(let error):
                        self?.latestError = error
                        self?.presentAlert = true
                    }
                },
                receiveValue: { [weak self] response in
                    self?.items = response.items
                }
            )
    }
}
