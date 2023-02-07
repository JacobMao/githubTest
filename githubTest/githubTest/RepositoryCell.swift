import SwiftUI

struct RepositoryCell: View {
    @State private var viewModel: RepositoryCellViewModel
    
    init(viewModel: RepositoryCellViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            viewModel.fullNameText
                .frame(alignment: ViewModel.Design.Cell.FullName.frameAlignment)
                .multilineTextAlignment(ViewModel.Design.Cell.FullName.textAlignment)
                .lineLimit(ViewModel.Design.Cell.FullName.lineLimit)
            viewModel.descriptionText
            
            viewModel.starsText
        }
    }
}
