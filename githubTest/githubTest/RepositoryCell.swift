import SwiftUI

struct RepositoryCell: View {
    @State private var model: RepositoryItem
    
    init(model: RepositoryItem) {
        self.model = model
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(model.full_name)
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(alignment: .center)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
            
            if !model.description.isEmpty {
                Text(model.description)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
                
            Text("stars: \(model.stargazers_count)" )
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(.gray)
        }
    }
}
