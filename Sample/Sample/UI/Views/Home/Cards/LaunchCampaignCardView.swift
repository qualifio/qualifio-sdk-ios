import SwiftUI

internal struct LaunchCampaignCardView: View {
    internal let onLaunchCampaign: (String) -> Void

    @State private var text: String = ""

    internal var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "newspaper")

                    Text(String(localized: "home_launch_campaign_card_title"))
                        .font(.body)
                }

                TextField(String(localized: "home_launch_campaign_card_input"), text: $text)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .lineLimit(1)

                Button {
                    onLaunchCampaign(text)
                } label: {
                    Text(String(localized: "home_launch_campaign_card_button"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    LaunchCampaignCardView(
        onLaunchCampaign: { _ in }
    )
}
