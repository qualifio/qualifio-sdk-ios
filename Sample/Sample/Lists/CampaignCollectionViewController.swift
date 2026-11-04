import UIKit
import QualifioKit

final class CampaignCollectionViewController: UICollectionViewController {
    enum Layout {
        case compositional
        case flow
    }

    private let layout: Layout

    init(layout: Layout) {
        self.layout = layout

        switch layout {
        case .compositional:
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            super.init(collectionViewLayout: UICollectionViewCompositionalLayout(section: section))

        case .flow:
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.minimumLineSpacing = 8
            super.init(collectionViewLayout: flowLayout)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.register(TextCollectionViewCell.self, forCellWithReuseIdentifier: "text")
        collectionView.register(CampaignCollectionViewCell.self, forCellWithReuseIdentifier: "campaign")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: FullWidthCollectionViewCell
        if indexPath.item == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "campaign", for: indexPath) as! CampaignCollectionViewCell
        } else {
            let textCell = collectionView.dequeueReusableCell(withReuseIdentifier: "text", for: indexPath) as! TextCollectionViewCell
            textCell.label.text = indexPath.item == 0 ? "Item above campaign" : "Item below campaign"
            cell = textCell
        }

        // Flow layout cells don't get a width from the layout, so give them the list's width.
        if layout == .flow {
            cell.setWidth(collectionView.bounds.width)
        }

        return cell
    }
}

private class FullWidthCollectionViewCell: UICollectionViewCell {
    private lazy var widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)

    func setWidth(_ width: CGFloat) {
        widthConstraint.constant = width
        widthConstraint.isActive = true
    }
}

private final class TextCollectionViewCell: FullWidthCollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground

        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}

private final class CampaignCollectionViewCell: FullWidthCollectionViewCell {
    private let campaignView = QualifioInlineCampaignView(
        campaign: Qualifio.DEFAULT_CAMPAIGN,
        autoScrollOnPageLoadEnabled: true
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .orange

        campaignView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(campaignView)

        NSLayoutConstraint.activate([
            campaignView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            campaignView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            campaignView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            campaignView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}
