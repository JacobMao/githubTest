import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack (alignment: .center) {
            HStack (alignment: .center) {
                TextField("input keyword", text: $viewModel.searchText)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
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
