import QualifioKit
import SwiftUI

internal struct SwiftUIInlineCampaignCardView: View {
    internal let campaign: String

    @State private var isCampaignVisible = true

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
            }
        }
    }
}

#Preview {
    SwiftUIInlineCampaignCardView(campaign: sampleCampaign)
}
