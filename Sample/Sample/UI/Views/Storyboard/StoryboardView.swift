import SwiftUI
import UIKit

internal struct StoryboardView: UIViewControllerRepresentable {
    internal func makeUIViewController(context: Context) -> UIViewController {
        UIStoryboard(name: "InlineCampaign", bundle: nil).instantiateInitialViewController()!
    }

    internal func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}

#Preview {
    StoryboardView()
}
