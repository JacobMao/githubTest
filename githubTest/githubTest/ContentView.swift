import SwiftUI
import Combine

struct ContentView: View {
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = DataService().requestData(with: "Swift")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    print(result)
                },
                receiveValue: { response in
                    print(response)
                }
            )
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
