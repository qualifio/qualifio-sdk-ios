import SwiftUI
import QualifioKit

struct ContentView: View {
    @State private var campaign = Qualifio.DEFAULT_CAMPAIGN

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "newspaper")
                        .imageScale(.large)
                        .foregroundStyle(.tint)

                    Text("Campaign inline (SwiftUI)")
                        .font(.headline)
                }

                QualifioInlineCampaign(
                    campaign: campaign,
                    autoScrollOnPageLoadEnabled: true
                )
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.orange)

                HStack(spacing: 8) {
                    Button("Load sdk") {
                        campaign = Qualifio.DEFAULT_CAMPAIGN
                    }
                    .frame(maxWidth: .infinity)

                    Button("Load sdk-xmas") {
                        campaign = "sdk-xmas"
                    }
                    .frame(maxWidth: .infinity)
                }

                Button("Launch Campaign") {
                    Task {
                        do {
                            try await Qualifio.shared.launchCampaign(campaign)
                        } catch {
                            print("Failed to launch campaign:", error)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}

#Preview {
    ContentViewPreview()
}

private struct ContentViewPreview: View {
    var body: some View {
        ContentView()
    }
}
