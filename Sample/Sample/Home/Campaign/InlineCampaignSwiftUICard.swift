import SwiftUI
import QualifioKit

struct InlineCampaignSwiftUICard: View {
    let campaign: String

    @State private var isCampaignVisible = true

    var body: some View {
        HomeCard(title: "Inline campaign (SwiftUI)") {
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
                Text(isCampaignVisible ? "Remove view" : "Add view")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    InlineCampaignSwiftUICard(campaign: sampleCampaign)
}
