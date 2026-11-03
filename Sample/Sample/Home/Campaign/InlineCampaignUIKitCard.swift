import SwiftUI
import UIKit
import QualifioKit

struct InlineCampaignUIKitCard: View {
    @State private var campaignViewReference = CampaignViewReference()
    @State private var isCampaignAdded = true

    var body: some View {
        HomeCard(title: "Inline campaign (UIKit)") {
            if isCampaignAdded {
                InlineCampaignUIKitView(reference: campaignViewReference)
                    .frame(maxWidth: .infinity)
            }

            Button {
                isCampaignAdded.toggle()
            } label: {
                Text(isCampaignAdded ? "Remove view" : "Add view")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            HStack(spacing: 8) {
                Button {
                    campaignViewReference.view?.loadCampaign(Qualifio.DEFAULT_CAMPAIGN)
                } label: {
                    Text("Load sdk")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    campaignViewReference.view?.loadCampaign("sdk-xmas")
                } label: {
                    Text("Load sdk-xmas")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
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
    InlineCampaignUIKitCard()
}
