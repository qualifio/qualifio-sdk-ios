import Combine
import Foundation
import OSLog
import QualifioKit

internal class HomeViewModel: ObservableObject {
    @Published internal private(set) var inlineCampaign = sampleCampaign

    internal func launchCampaign(_ value: String) {
        let campaign = resolvedCampaign(value)

        Task {
            do {
                try await Qualifio.shared.launchCampaign(campaign)
            } catch {
                Logger.main.error("Failed to launch campaign: \(error)")
            }
        }
    }

    internal func loadInlineCampaign(_ value: String) {
        inlineCampaign = resolvedCampaign(value)
    }

    private func resolvedCampaign(_ value: String) -> String {
        let campaign = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return campaign.isEmpty ? sampleCampaign : campaign
    }
}
