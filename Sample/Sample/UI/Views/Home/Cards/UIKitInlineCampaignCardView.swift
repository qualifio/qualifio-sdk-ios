import SwiftUI
import UIKit
import QualifioKit

internal struct UIKitInlineCampaignCardView: View {
    @State private var campaignViewReference = CampaignViewReference()
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
                    InlineCampaignUIKitView(reference: campaignViewReference)
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

                HStack(spacing: 8) {
                    Button {
                        campaignViewReference.view?.loadCampaign(Qualifio.DEFAULT_CAMPAIGN)
                    } label: {
                        Text(String(localized: "home_inline_campaign_card_load_sdk_button"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        campaignViewReference.view?.loadCampaign("sdk-xmas")
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

private final class CampaignViewReference {
    weak var view: QualifioInlineCampaignView?
}

private struct InlineCampaignUIKitView: UIViewRepresentable {
    let reference: CampaignViewReference

    func makeUIView(context: Context) -> QualifioInlineCampaignView {
        let view = QualifioInlineCampaignView(
            campaign: Qualifio.DEFAULT_CAMPAIGN,
            autoScrollOnPageLoadEnabled: true
        )
        reference.view = view
        return view
    }

    func updateUIView(_ view: QualifioInlineCampaignView, context: Context) {}
}

#Preview {
    UIKitInlineCampaignCardView()
}
