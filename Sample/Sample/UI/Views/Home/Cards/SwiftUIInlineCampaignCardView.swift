import QualifioKit
import SwiftUI

internal struct SwiftUIInlineCampaignCardView: View {
    @State private var campaign = Qualifio.DEFAULT_CAMPAIGN
    @State private var isCampaignVisible = true

    @State private var text: String = ""

    internal var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "newspaper")

                    Text(String(localized: "home_swiftui_inline_campaign_card_title"))
                        .font(.body)
                }

                if isCampaignVisible {
                    QualifioInlineCampaign(
                        campaign: campaign,
                        autoScrollOnPageLoadEnabled: true
                    )
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.orange)
                }

                Button {
                    isCampaignVisible.toggle()
                } label: {
                    Text(isCampaignVisible ?
                         String(localized: "home_inline_campaign_card_remove_button") :
                         String(localized: "home_inline_campaign_card_add_button")
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                HStack(spacing: 8) {
                    Button {
                        campaign = Qualifio.DEFAULT_CAMPAIGN
                    } label: {
                        Text(String(localized: "home_inline_campaign_card_load_sdk_button"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        campaign = "sdk-xmas"
                    } label: {
                        Text(String(localized: "home_inline_campaign_card_load_xmas_button"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    SwiftUIInlineCampaignCardView()
}
