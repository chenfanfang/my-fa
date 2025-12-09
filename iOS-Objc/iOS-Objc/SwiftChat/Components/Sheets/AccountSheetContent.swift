import UIKit

@available(iOS 15.0, *)
final class AccountSheetContent: UIView, UITableViewDataSource, UITableViewDelegate {
    private let accounts: [(String, String, String)]
    private let onSelect: ((String, String, String)) -> Void
    private let table = UITableView(frame: .zero, style: .plain)
    private var tableHeight: NSLayoutConstraint?

    init(accounts: [(String, String, String)], onSelect: @escaping ((String, String, String)) -> Void) {
        self.accounts = accounts
        self.onSelect = onSelect
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "选择账户"
        title.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        title.textAlignment = .center

        let closeBtn = UIButton(type: .system)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.setTitle("返回", for: .normal)
        closeBtn.addAction(UIAction { _ in FullscreenSheet.dismiss() }, for: .touchUpInside)

        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = UIColor.separator.withAlphaComponent(0.4)

        addSubview(title)
        addSubview(closeBtn)
        addSubview(sep)

        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = 76
        table.estimatedRowHeight = 76
        table.dataSource = self
        table.delegate = self
        table.alwaysBounceVertical = true
        table.register(AttachmentContextProvider.AccountCell.self, forCellReuseIdentifier: "AccountCell")
        addSubview(table)

        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            closeBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.centerYAnchor.constraint(equalTo: closeBtn.centerYAnchor),

            sep.topAnchor.constraint(equalTo: closeBtn.bottomAnchor, constant: 12),
            sep.leadingAnchor.constraint(equalTo: leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 1),

            table.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            table.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            table.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

        // Initial height calculation after first layout
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.table.reloadData()
            self.updateTableHeight()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateTableHeight()
    }

    private func updateTableHeight() {
        // Calculate desired height: min(contentHeight, 60% of screen height)
        let screenMax = UIScreen.main.bounds.height * 0.6
        let headerApprox: CGFloat = 12 /*top*/ + 20 /*title line height*/ + 12 /*spacing*/ + 1 /*sep*/ + 12 /*table top*/ + 12 /*table bottom*/
        let rowsHeight = CGFloat(accounts.count) * table.rowHeight
        var desired = rowsHeight + 0 // cells only; paddings handled by constraints
        desired = min(desired, max(200, screenMax - headerApprox))

        if tableHeight == nil {
            tableHeight = table.heightAnchor.constraint(equalToConstant: desired)
            tableHeight?.priority = .required
            tableHeight?.isActive = true
        } else if abs((tableHeight?.constant ?? 0) - desired) > 1 {
            tableHeight?.constant = desired
        }
        table.isScrollEnabled = rowsHeight > desired
    }

    // MARK: UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { accounts.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AttachmentContextProvider.AccountCell
        let acc = accounts[indexPath.row]
        cell.configure(name: acc.0, balance: acc.1, tagText: acc.2)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let acc = accounts[indexPath.row]
        onSelect(acc)
        FullscreenSheet.dismiss()
    }
}
