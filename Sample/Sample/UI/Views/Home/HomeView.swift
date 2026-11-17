import SwiftUI

internal struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    internal var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ContentCardView(
                    title: String(localized: "home_content_card_title"),
                    content: String(localized: "home_content_card_content")
                )

                LaunchCampaignCardView(
                    onLaunchCampaign: { campaign in
                        viewModel.launchCampaign(campaign)
                    }
                )

                SwiftUIInlineCampaignCardView()

                UIKitInlineCampaignCardView()

                OthersCardView()

                ContentCardView(
                    title: String(localized: "home_content_card_title"),
                    content: String(localized: "home_content_card_content")
                )
            }
            .padding()
        }
        .navigationTitle(String(localized: "home_title"))
    }
}

#Preview {
    HomeView()
}
