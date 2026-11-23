import SwiftUI

internal struct OthersCardView: View {
    internal var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink {
                    ListsView()
                } label: {
                    NavigationRow(
                        title: String(localized: "home_lists_title"),
                        icon: "list.bullet",
                        backgroundColor: .red
                    )
                }

                Divider()

                NavigationLink {
                    StoryboardView()
                } label: {
                    NavigationRow(
                        title: String(localized: "home_storyboard_title"),
                        icon: "rectangle.on.rectangle",
                        backgroundColor: .orange
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }
}

private struct NavigationRow: View {
    let title: String
    let icon: String
    let backgroundColor: Color

    var body: some View {
        HStack {
            Label {
                Text(title)
            } icon: {
                ListIconView(
                    icon: icon,
                    foregroundColor: .white,
                    backgroundColor: backgroundColor
                )
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
        OthersCardView()
}
