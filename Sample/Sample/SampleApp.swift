import SwiftUI

@main
internal struct SampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) internal var appDelegate

    internal var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
