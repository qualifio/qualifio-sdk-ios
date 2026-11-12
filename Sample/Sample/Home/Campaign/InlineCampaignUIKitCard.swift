import SwiftUI
import UIKit
import QualifioKit

struct InlineCampaignUIKitCard: View {
    let campaign: String

    @State private var isCampaignAdded = true

    var body: some View {
        HomeCard(title: "Inline campaign (UIKit)") {
            if isCampaignAdded {
                InlineCampaignUIKitView(campaign: campaign)
                    .frame(maxWidth: .infinity)
            }

            Button {
                isCampaignAdded.toggle()
            } label: {
                Text(isCampaignAdded ? "Remove view" : "Add view")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct InlineCampaignUIKitView: UIViewRepresentable {
    let campaign: String

    func makeUIView(context: Context) -> QualifioInlineCampaignView {
        QualifioInlineCampaignView(
            campaign: campaign,
            autoScrollOnPageLoadEnabled: true
        )
    }

    func updateUIView(_ view: QualifioInlineCampaignView, context: Context) {
        if view.campaign != campaign {
            view.loadCampaign(campaign)
        }
    }
}

#Preview {
    InlineCampaignUIKitCard(campaign: sampleCampaign)
}
