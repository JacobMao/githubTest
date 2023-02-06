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
                RepositoryCell(model: item)
            }
            .listStyle(.plain)
        }
    }
}


