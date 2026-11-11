import Combine
import Foundation
import OSLog
import QualifioKit

internal class HomeViewModel: ObservableObject {
    internal func launchCampaign(_ value: String) {
        Task {
            do {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    try await Qualifio.shared.launchCampaign()
                } else {
                    try await Qualifio.shared.launchCampaign(trimmed)
                }
            } catch {
                Logger.main.error("Failed to launch campaign: \(error)")
            }
        }
    }
}
