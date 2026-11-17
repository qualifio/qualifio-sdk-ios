import Combine
import SwiftUI

internal struct ContentView: View {
    @StateObject private var router = ContentRouter.main

    internal var body: some View {
        ZStack {
            switch router.route {
            case .splash:
                SplashView()
            case .configuration:
                ConfigurationView()
            case .main:
                MainView()
            }
        }
        .environmentObject(router)
    }
}

internal class ContentRouter: ObservableObject {
    internal static let main = ContentRouter(.splash)

    @Published internal var route: Route

    internal init(_ route: Route) {
        self.route = route
    }

    internal enum Route {
        case splash
        case configuration
        case main
    }
}

#Preview {
    ContentView()
}
