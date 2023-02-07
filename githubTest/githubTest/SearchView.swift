import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack (alignment: .center) {
            HStack (alignment: .center) {
                TextField(ViewModel.Design.SearchView.placeholder,
                          text: $viewModel.searchText
                )
                .textFieldStyle(ViewModel.Design.SearchView.style)
                .multilineTextAlignment(ViewModel.Design.SearchView.textAlignment)
                .padding(ViewModel.Design.SearchView.padding)
                .font(ViewModel.Design.SearchView.font)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
