import SwiftUI

@main
struct CardDueApp: App {
    @State private var store = CardStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
