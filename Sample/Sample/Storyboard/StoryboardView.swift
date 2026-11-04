import SwiftUI
import UIKit

struct StoryboardView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIStoryboard(name: "InlineCampaign", bundle: nil).instantiateInitialViewController()!
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {}
}

#Preview {
    StoryboardView()
}
