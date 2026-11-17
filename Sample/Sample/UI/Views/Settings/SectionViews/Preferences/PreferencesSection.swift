import SwiftUI

internal struct PreferencesSection: View {
    @Preference(\.showCampaignAtLaunch) private var showCampaignAtLaunch: Bool

    internal var body: some View {
        Section {
            Toggle(isOn: $showCampaignAtLaunch) {
                Label {
                    Text(String(localized: "settings_preferences_campaign_launch_label"))
                } icon: {
                    ListIconView(
                        icon: "newspaper.fill",
                        foregroundColor: .white,
                        backgroundColor: .orange
                    )
                }
            }
        } header: {
            Text(String(localized: "settings_preferences_title"))
        }
    }
}

#Preview {
    PreferencesSection()
}
