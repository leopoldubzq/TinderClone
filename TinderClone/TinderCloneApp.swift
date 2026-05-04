import SwiftUI

@main
struct TinderCloneApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(NavigationManager())
        }
    }
}
