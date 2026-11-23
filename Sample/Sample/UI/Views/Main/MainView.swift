import SwiftUI

internal struct MainView: View {
    internal var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label(String(localized: "home_title"), systemImage: "house.fill")
            }

            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label(String(localized: "settings_title"), systemImage: "gear")
            }
        }
    }
}

#Preview {
    MainView()
}
