import SwiftUI

@main
struct SampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem { Label("Home", systemImage: "house") }

                ListsView()
                    .tabItem { Label("Lists", systemImage: "list.bullet") }

                StoryboardView()
                    .tabItem { Label("Storyboard", systemImage: "rectangle.on.rectangle") }
            }
        }
    }
}
