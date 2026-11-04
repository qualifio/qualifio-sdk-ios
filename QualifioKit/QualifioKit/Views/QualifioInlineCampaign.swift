import SwiftUI
import UIKit

/// Displays a Qualifio campaign inline in a SwiftUI view.
public struct QualifioInlineCampaign: View {
    private let campaign: String
    private let autoScrollOnPageLoadEnabled: Bool

    @State private var contentHeight: CGFloat = 0

    /// Creates an inline campaign view and loads the provided `campaign`.
    ///
    /// - Parameter autoScrollOnPageLoadEnabled: When true, subsequent campaign page loads request that
    ///   the parent scroll container bring this view back to its top edge.
    public init(
        campaign: String = Qualifio.DEFAULT_CAMPAIGN,
        autoScrollOnPageLoadEnabled: Bool = true
    ) {
        self.campaign = campaign
        self.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled
    }

    public var body: some View {
        QualifioInlineCampaignRepresentable(
            campaign: campaign,
            autoScrollOnPageLoadEnabled: autoScrollOnPageLoadEnabled,
            onContentHeightChanged: { height in
                DispatchQueue.main.async {
                    guard height >= 0, height != contentHeight else {
                        return
                    }

                    contentHeight = height
                }
            }
        )
        .frame(height: contentHeight)
    }
}

private struct QualifioInlineCampaignRepresentable: UIViewRepresentable {
    let campaign: String
    let autoScrollOnPageLoadEnabled: Bool
    let onContentHeightChanged: (CGFloat) -> Void

    func makeUIView(context: Context) -> QualifioInlineCampaignView {
        let view = QualifioInlineCampaignView(
            campaign: campaign,
            autoScrollOnPageLoadEnabled: autoScrollOnPageLoadEnabled
        )
        view.onContentHeightChanged = onContentHeightChanged
        return view
    }

    func updateUIView(_ view: QualifioInlineCampaignView, context: Context) {
        view.onContentHeightChanged = onContentHeightChanged

        view.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled

        if view.campaign != campaign {
            view.loadCampaign(campaign)
        }
    }
}
