import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            Section(header: SearchView().environmentObject(viewModel)) {}
            
            List(viewModel.items) { item in
                let cellViewModel = viewModel.makeCellViewModel(by: item)
                RepositoryCell(viewModel: cellViewModel)
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
        }
        .alert(isPresented: $viewModel.presentAlert) {
            return Alert(
                title: viewModel.errorTitle,
                message: Text(viewModel.latestError?.localizedDescription ?? "")
            )
        }
    }
}

