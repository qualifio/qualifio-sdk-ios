import SwiftUI

struct HomeCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "newspaper")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text(title)
                    .font(.headline)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        .padding(16)
    }
}

struct ContentCard: View {
    let title: String
    let content: String

    var body: some View {
        HomeCard(title: title) {
            Text(content)
        }
    }
}

#Preview {
    ContentCard(
        title: "Content",
        content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    )
}
