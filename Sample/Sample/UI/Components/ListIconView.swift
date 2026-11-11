import SwiftUI

internal struct ListIconView: View {
    internal let icon: String
    internal let foregroundColor: Color
    internal let backgroundColor: Color

    private let isSystemSymbol: Bool

    internal init(icon: String, foregroundColor: Color, backgroundColor: Color) {
        self.icon = icon
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.isSystemSymbol = UIImage(systemName: icon) != nil
    }

    internal var body: some View {
        (isSystemSymbol ? Image(systemName: icon) : Image(icon))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(6)
            .frame(width: 28, height: 28, alignment: .center)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview {
    HStack {
        ListIconView(
            icon: "sensor.tag.radiowaves.forward",
            foregroundColor: Color.white,
            backgroundColor: Color.blue
        )

        ListIconView(
            icon: "key.shield.badge.plus",
            foregroundColor: Color.white,
            backgroundColor: Color.blue
        )
    }
}
