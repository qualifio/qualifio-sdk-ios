import SwiftUI
import QualifioKit

struct CampaignCard: View {
    let onLoadInlineCampaign: (String) -> Void

    @State private var launchCampaign = sampleCampaign
    @State private var inlineCampaign = sampleCampaign

    var body: some View {
        HomeCard(title: "Campaign") {
            CampaignTextField(title: "Campaign Path", text: $launchCampaign)

            Button {
                let campaign = resolvedCampaign(launchCampaign)

                Task {
                    do {
                        try await Qualifio.shared.launchCampaign(campaign)
                    } catch {
                        print("Failed to launch campaign:", error)
                    }
                }
            } label: {
                Text("Launch Campaign")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            CampaignTextField(title: "Inline Campaign Path", text: $inlineCampaign)

            Button {
                onLoadInlineCampaign(resolvedCampaign(inlineCampaign))
            } label: {
                Text("Load Inline Campaign")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func resolvedCampaign(_ text: String) -> String {
        let campaign = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return campaign.isEmpty ? sampleCampaign : campaign
    }
}

private struct CampaignTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
    }
}

#Preview {
    CampaignCard(onLoadInlineCampaign: { _ in })
}
