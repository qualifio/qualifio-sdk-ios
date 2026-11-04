import UIKit
import QualifioKit

final class CampaignTableViewController: UITableViewController {
    init() {
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "text")
        tableView.register(CampaignTableViewCell.self, forCellReuseIdentifier: "campaign")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "campaign", for: indexPath)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = indexPath.row == 0 ? "Row above campaign" : "Row below campaign"
        cell.contentConfiguration = content
        return cell
    }
}

private final class CampaignTableViewCell: UITableViewCell {
    private let campaignView = QualifioInlineCampaignView(
        campaign: Qualifio.DEFAULT_CAMPAIGN,
        autoScrollOnPageLoadEnabled: true
    )

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
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
