import SwiftUI

internal struct ContentCardView: View {
    internal let title: String
    internal let content: String

    internal var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "newspaper")

                    Text(title)
                        .font(.body)
                }

                HStack {
                    Text(content)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ContentCardView(
        title: "Title",
        content: "Content"
    )
}
