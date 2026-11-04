import SwiftUI
import QualifioKit

struct CampaignCard: View {
    @State private var text = ""

    var body: some View {
        HomeCard(title: "Campaign") {
            TextField("Campaign Path", text: $text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button {
                Task {
                    do {
                        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            try await Qualifio.shared.launchCampaign()
                        } else {
                            try await Qualifio.shared.launchCampaign(text)
                        }
                    } catch {
                        print("Failed to launch campaign:", error)
                    }
                }
            } label: {
                Text("Launch Campaign")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    CampaignCard()
}
