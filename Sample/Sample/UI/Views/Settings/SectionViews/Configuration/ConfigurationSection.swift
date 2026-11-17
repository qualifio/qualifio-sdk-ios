import SwiftUI

internal struct ConfigurationSection: View {
    @Preference(\.domain)  private var domain

    internal var body: some View {
        Section {
            HStack {
                Text(String(localized: "settings_configuration_domain_label"))
                    .bold()

                Spacer()

                Text(String(domain ?? "nil"))
            }
        } header: {
            Text(String(localized: "settings_configuration_title"))
        }
    }
}

#Preview {
    ConfigurationSection()
}
