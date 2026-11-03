import SwiftUI
import QualifioKit

struct InlineCampaignSwiftUICard: View {
    @State private var campaign = Qualifio.DEFAULT_CAMPAIGN
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

            HStack(spacing: 8) {
                Button {
                    campaign = Qualifio.DEFAULT_CAMPAIGN
                } label: {
                    Text("Load sdk")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    campaign = "sdk-xmas"
                } label: {
                    Text("Load sdk-xmas")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    InlineCampaignSwiftUICard()
}
