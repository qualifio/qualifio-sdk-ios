import SwiftUI

internal struct CampaignCardView: View {
    internal let onLaunchCampaign: (String) -> Void
    internal let onLoadInlineCampaign: (String) -> Void

    @State private var launchCampaign = sampleCampaign
    @State private var inlineCampaign = sampleCampaign

    internal var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "newspaper")

                    Text(String(localized: "home_campaign_card_title"))
                        .font(.body)
                }

                CampaignTextField(
                    title: String(localized: "home_campaign_card_launch_input"),
                    text: $launchCampaign
                )

                Button {
                    onLaunchCampaign(launchCampaign)
                } label: {
                    Text(String(localized: "home_campaign_card_launch_button"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                CampaignTextField(
                    title: String(localized: "home_campaign_card_inline_input"),
                    text: $inlineCampaign
                )

                Button {
                    onLoadInlineCampaign(inlineCampaign)
                } label: {
                    Text(String(localized: "home_campaign_card_inline_button"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

private struct CampaignTextField: View {
    fileprivate let title: String
    @Binding fileprivate var text: String

    fileprivate var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.roundedBorder)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.URL)
            .lineLimit(1)
    }
}

#Preview {
    CampaignCardView(
        onLaunchCampaign: { _ in },
        onLoadInlineCampaign: { _ in }
    )
}
