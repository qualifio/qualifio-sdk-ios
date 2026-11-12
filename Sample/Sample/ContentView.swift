import SwiftUI

private let contentTitle = "Content"
private let contentText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam fermentum urna elit, non elementum justo convallis in. Etiam porta justo vulputate lacus fermentum, ut accumsan neque malesuada. Pellentesque sit amet ipsum suscipit, feugiat nisi at, venenatis ante. Donec sagittis non metus in tempus. Nam felis justo, tincidunt et accumsan eu, blandit id metus."

struct ContentView: View {
    @State private var inlineCampaign = sampleCampaign

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ContentCard(title: contentTitle, content: contentText)

                CampaignCard(onLoadInlineCampaign: { inlineCampaign = $0 })

                InlineCampaignUIKitCard(campaign: inlineCampaign)

                InlineCampaignSwiftUICard(campaign: inlineCampaign)

                ContentCard(title: contentTitle, content: contentText)
            }
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
