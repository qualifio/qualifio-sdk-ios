import SwiftUI
import UIKit
import QualifioKit

internal struct UIKitInlineCampaignCardView: View {
    internal let campaign: String

    @State private var isCampaignAdded = true

    internal var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "newspaper")

                    Text(String(localized: "home_uikit_inline_campaign_card_title"))
                        .font(.body)
                }

                if isCampaignAdded {
                    InlineCampaignUIKitView(campaign: campaign)
                        .frame(maxWidth: .infinity)
                }

                Button {
                    isCampaignAdded.toggle()
                } label: {
                    Text(isCampaignAdded ?
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

private struct InlineCampaignUIKitView: UIViewRepresentable {
    fileprivate let campaign: String

    fileprivate func makeUIView(context: Context) -> QualifioInlineCampaignView {
        QualifioInlineCampaignView(
            campaign: campaign,
            autoScrollOnPageLoadEnabled: true
        )
    }

    fileprivate func updateUIView(_ view: QualifioInlineCampaignView, context: Context) {
        if view.campaign != campaign {
            view.loadCampaign(campaign)
        }
    }
}

#Preview {
    UIKitInlineCampaignCardView(campaign: sampleCampaign)
}
