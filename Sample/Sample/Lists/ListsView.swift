import SwiftUI
import UIKit

struct ListsView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: ListsViewController())
    }

    func updateUIViewController(_ viewController: UINavigationController, context: Context) {}
}

private final class ListsViewController: UIViewController {
    private enum Mode: Int, CaseIterable {
        case table
        case compositionalCollection
        case flowCollection

        var title: String {
            switch self {
            case .table: "Table"
            case .compositionalCollection: "Collection"
            case .flowCollection: "Flow"
            }
        }
    }

    private let modeControl = UISegmentedControl(items: Mode.allCases.map(\.title))
    private var currentViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        modeControl.selectedSegmentIndex = Mode.table.rawValue
        modeControl.apportionsSegmentWidthsByContent = true
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        navigationItem.titleView = modeControl

        showMode(.table)
    }

    @objc private func modeChanged() {
        guard let mode = Mode(rawValue: modeControl.selectedSegmentIndex) else {
            return
        }

        showMode(mode)
    }

    private func showMode(_ mode: Mode) {
        currentViewController?.willMove(toParent: nil)
        currentViewController?.view.removeFromSuperview()
        currentViewController?.removeFromParent()

        let viewController: UIViewController
        switch mode {
        case .table:
            viewController = CampaignTableViewController()
        case .compositionalCollection:
            viewController = CampaignCollectionViewController(layout: .compositional)
        case .flowCollection:
            viewController = CampaignCollectionViewController(layout: .flow)
        }

        addChild(viewController)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        currentViewController = viewController
    }
}

#Preview {
    ListsView()
}
