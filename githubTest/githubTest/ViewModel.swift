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
            static let placeholder = "input keyword"
            static let textAlignment = TextAlignment.center
            static let style = RoundedBorderTextFieldStyle.roundedBorder
        }
        
        enum Cell {
            fileprivate static let font = Font.system(size: 16)
            fileprivate static let fontWeight = Font.Weight.bold
            
            enum FullName {
                fileprivate static let color = Color.blue
                static let frameAlignment = Alignment.center
                static let textAlignment = TextAlignment.leading
                static let lineLimit = 1
            }
            
            enum Description {
                fileprivate static let color = Color.black
            }
            
            enum Stars {
                fileprivate static let color = Color.gray
            }
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
                
                strongSelf.loadData(with: value)
            }
            .store(in: &cancellables)
    }
}

// MARK: Request datas Methods
extension ViewModel {
    func loadData(with keyword: String) {
        currentTask?.cancel()
        currentTask = nil
        
        guard !keyword.isEmpty else {
            items = [RepositoryItem]()
            return
        }
        
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

// MARK: Cell viewModel methods
extension ViewModel {
    func makeCellViewModel(by item: RepositoryItem) -> RepositoryCellViewModel {
        return RepositoryCellViewModel(
            id: item.id,
            fullNameText: makeFullNameText(item.full_name),
            descriptionText: makeDescriptionText(item.description ?? ""),
            starsText: makeStarsText(item.stargazers_count)
        )
    }
    
    private func makeFullNameText(_ fullName: String) -> Text {
        Text(fullName)
            .font(Design.Cell.font)
            .fontWeight(Design.Cell.fontWeight)
            .foregroundColor(Design.Cell.FullName.color)
    }
    
    private func makeDescriptionText(_ description: String) -> Text {
        Text(description)
            .font(Design.Cell.font)
            .fontWeight(Design.Cell.fontWeight)
            .foregroundColor(Design.Cell.Description.color)
    }
    
    private func makeStarsText(_ starsCount: Int) -> Text {
        Text("stars: \(starsCount)")
            .font(Design.Cell.font)
            .fontWeight(Design.Cell.fontWeight)
            .foregroundColor(Design.Cell.Stars.color)
    }
}
