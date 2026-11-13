import SwiftUI

internal struct SettingsView: View {
    internal var body: some View {
        List {
            ConfigurationSection()

            SecureTokenSection()

            PreferencesSection()

            Section {
                Text(verbatim: "Version \(Bundle.main.applicationVersion)")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)

        }
        .navigationTitle(String(localized: "settings_title"))
    }
}

#Preview {
    SettingsView()
}
