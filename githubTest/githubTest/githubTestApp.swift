import SwiftUI

@main
struct githubTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ViewModel(dataService: DataService()))
        }
    }
}
