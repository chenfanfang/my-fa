import Foundation
import UIKit
import ConvoUI

@available(iOS 15.0, *)
@MainActor
final class AttachmentContextProvider: NSObject, @preconcurrency ConvoUIContextProvider {
    var id: String { "chatkit.attachment" }

// MARK: - AccountCell

final class AccountCell: UITableViewCell {
    private let container = UIView()
    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()
    private let pill = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .tertiarySystemBackground
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        contentView.addSubview(container)

        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label

        balanceLabel.font = UIFont.systemFont(ofSize: 14)
        balanceLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, balanceLabel])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        pill.textColor = .white
        pill.backgroundColor = .systemBlue
        pill.layer.cornerRadius = 12
        pill.clipsToBounds = true
        pill.setContentHuggingPriority(.required, for: .horizontal)
        pill.setContentCompressionResistancePriority(.required, for: .horizontal)
        pill.heightAnchor.constraint(greaterThanOrEqualToConstant: 24).isActive = true

        let row = UIStackView(arrangedSubviews: [textStack, pill])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(row)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])
    }

    func configure(name: String, balance: String, tagText: String) {
        nameLabel.text = name
        balanceLabel.text = balance
        pill.text = "  \(tagText)  "
    }
}
    var title: String { "上下文" }
    var iconName: String { "paperclip" }
    var isAvailable: Bool { true }
    var priority: Int { 120 }
    var maximumAttachmentCount: Int { 1 }
    var shouldUseContainerPanel: Bool { true }

    func makeContext() async throws -> (any ConvoUIContextItem)? { nil }

    func createCollectorView(onConfirm: @escaping ((any ConvoUIContextItem)?) -> Void) -> UIView? {
        let v = AttachmentCollectorView()
        v.onConfirm = onConfirm
        return v
    }
    func createDetailView(for item: any ConvoUIContextItem, onDismiss: @escaping () -> Void) -> UIView? {
        
        return nil
    }
    
    func localizedDescription(for item: any ConvoUIContextItem) -> String { item.displayName }
    
}

struct AttachmentContextItem: ConvoUIContextItem {
    enum Kind { case timeRange(label: String), account(name: String, balance: String, tag: String), recentFile(name: String, date: String, size: String), upload }
    let id = UUID()
    let providerId = "chatkit.attachment"
    let type: String
    let kind: Kind

    init(kind: Kind) {
        self.kind = kind
        switch kind {
        case .timeRange: self.type = "timeRange"
        case .account: self.type = "account"
        case .recentFile: self.type = "recentFile"
        case .upload: self.type = "upload"
        }
    }

    var displayName: String {
        switch kind {
        case .timeRange(let label): return label
        case .account(let name, _, _): return name
        case .recentFile(let name, _, _): return name
        case .upload: return "上传新文件"
        }
    }

    var codablePayload: Encodable? {
        switch kind {
        case .timeRange(let label):
            return AttachmentPayload(kind: type, name: label, date: nil, size: nil, timestamp: Date().timeIntervalSince1970)
        case .account(let name, let balance, let tag):
            return AttachmentPayload(kind: type, name: name, date: balance, size: tag, timestamp: Date().timeIntervalSince1970)
        case .recentFile(let name, let date, let size):
            return AttachmentPayload(kind: type, name: name, date: date, size: size, timestamp: Date().timeIntervalSince1970)
        case .upload:
            return AttachmentPayload(kind: type, name: "上传新文件", date: nil, size: nil, timestamp: Date().timeIntervalSince1970)
        }
    }

    func encodeForTransport() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return try encoder.encode(codablePayload as? AttachmentPayload)
    }

    var encodingRepresentation: ConvoUIEncodingType { .json }

    var encodingMetadata: [String: String]? {
        var meta: [String: String] = [
            "provider": providerId,
            "type": type,
            "localizedDescription": humanReadableDescription
        ]
        switch kind {
        case .account(let name, let balance, let tag):
            meta["name"] = name
            meta["balance"] = balance
            meta["tag"] = tag
        case .recentFile(let name, let date, let size):
            meta["name"] = name
            meta["date"] = date
            meta["size"] = size
        default:
            break
        }
        return meta
    }

    var descriptionTemplates: [ContextDescriptionTemplate] {
        [
            ContextDescriptionTemplate(locale: "en", template: "{type}: {name}"),
            ContextDescriptionTemplate(locale: "zh-CN", template: "{type}: {name}")
        ]
    }

    var humanReadableDescription: String { displayName }

    func createPreviewView(onRemove: @escaping () -> Void) -> UIView? {
        // Blue outlined pill, dynamic width based on text, with close (x) button
        let text = humanReadableDescription
        let font = UIFont.systemFont(ofSize: 13, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let textSize = (text as NSString).size(withAttributes: attributes)

        let h: CGFloat = 34
        let horizontalPadding: CGFloat = 14
        let spacing: CGFloat = 8
        let closeSize: CGFloat = 16

        let width = ceil(horizontalPadding + textSize.width + spacing + closeSize + horizontalPadding)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: max(width, 72), height: h))
        container.backgroundColor = .clear
        container.layer.cornerRadius = h / 2
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemBlue.cgColor

        let title = UILabel()
        title.text = text
        title.font = font
        title.textColor = UIColor.systemBlue
        title.sizeToFit()
        let titleY = (h - title.bounds.height) / 2
        title.frame = CGRect(x: horizontalPadding, y: titleY, width: min(title.bounds.width, width), height: title.bounds.height)
        container.addSubview(title)

        let close = UIButton(type: .system)
        if let img = UIImage(systemName: "xmark") { close.setImage(img, for: .normal) } else { close.setTitle("×", for: .normal) }
        close.tintColor = UIColor.systemBlue
        close.setTitleColor(UIColor.systemBlue, for: .normal)
        close.contentEdgeInsets = .zero
        close.frame = CGRect(x: container.bounds.width - horizontalPadding - closeSize, y: (h - closeSize) / 2, width: closeSize, height: closeSize)
        close.addAction(UIAction { _ in onRemove() }, for: .touchUpInside)
        container.addSubview(close)

        return container
    }
}

struct AttachmentPayload: Codable {
    let kind: String
    let name: String?
    let date: String?
    let size: String?
    let timestamp: TimeInterval
}

@available(iOS 15.0, *)
@MainActor
final class AttachmentCollectorView: UIView {
    var onConfirm: (((any ConvoUIContextItem)?) -> Void)?

    private let commonLabel = UILabel()
    private let commonRow = UIStackView()
    private let recentLabel = UILabel()
    private let recentStack = UIStackView()
    private let uploadButton = UIButton(type: .system)

    private let scroll = UIScrollView()
    private let content = UIStackView()
    private var mockAccounts: [(String, String, String)] = []
    private weak var overlayDim: UIView?
    private weak var overlayPanel: UIView?
    private weak var accountTable: UITableView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override var intrinsicContentSize: CGSize { CGSize(width: UIView.noIntrinsicMetric, height: 560) }

    private func setup() {
        backgroundColor = .systemBackground

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.delaysContentTouches = false
        scroll.canCancelContentTouches = false
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scroll)
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -12),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -12),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -24)
        ])

        commonLabel.text = "常用上下文"
        commonLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        commonLabel.textColor = .secondaryLabel
        content.addArrangedSubview(commonLabel)

        commonRow.axis = .horizontal
        commonRow.spacing = 8
        commonRow.distribution = .fillEqually
        commonRow.isUserInteractionEnabled = true
        content.addArrangedSubview(commonRow)

        let timeBtn = makeTile(title: "时间范围", subtitle: "指定分析周期", systemImage: "clock")
        timeBtn.addTarget(self, action: #selector(onTapTimeRange), for: .touchUpInside)
        timeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapTimeRange)))
        timeBtn.accessibilityIdentifier = "attachment.tile.timerange"
        let acctBtn = makeTile(title: "选择账户", subtitle: "切换分析账户", systemImage: "person.crop.circle")
        acctBtn.addTarget(self, action: #selector(onTapAccount), for: .touchUpInside)
        acctBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapAccount)))
        acctBtn.accessibilityIdentifier = "attachment.tile.account"
        commonRow.addArrangedSubview(timeBtn)
        commonRow.addArrangedSubview(acctBtn)

        recentLabel.text = "最近上传"
        recentLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        recentLabel.textColor = .secondaryLabel
        content.addArrangedSubview(recentLabel)

        recentStack.axis = .vertical
        recentStack.spacing = 10
        content.addArrangedSubview(recentStack)

        let recents: [(String,String,String)] = [
            ("贵州茅台2024Q3财报.pdf","2024-11-15","2.3MB"),
            ("新能源行业研报.pdf","2024-11-10","4.1MB")
        ]
        for r in recents {
            let row = makeRecentRow(name: r.0, date: r.1, size: r.2)
            recentStack.addArrangedSubview(row)
        }

        let uploadContainer = UIView()
        uploadContainer.layer.cornerRadius = 12
        uploadContainer.layer.borderWidth = 1
        uploadContainer.layer.borderColor = UIColor.separator.withAlphaComponent(0.6).cgColor
        uploadContainer.layer.borderColor = UIColor.tertiaryLabel.withAlphaComponent(0.6).cgColor
        uploadContainer.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.translatesAutoresizingMaskIntoConstraints = false
        uploadButton.setImage(UIImage(systemName: "arrow.up.doc"), for: .normal)
        uploadButton.setTitle(" 上传新文件", for: .normal)
        uploadButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        uploadButton.tintColor = .label
        uploadButton.addTarget(self, action: #selector(tapUpload), for: .touchUpInside)
        uploadContainer.addSubview(uploadButton)
        content.addArrangedSubview(uploadContainer)

        NSLayoutConstraint.activate([
            uploadContainer.heightAnchor.constraint(equalToConstant: 120),
            uploadButton.centerXAnchor.constraint(equalTo: uploadContainer.centerXAnchor),
            uploadButton.centerYAnchor.constraint(equalTo: uploadContainer.centerYAnchor)
        ])
    }

    private func makeTile(title: String, subtitle: String, systemImage: String) -> UIButton {
        let v = UIButton(type: .system)
        // Remove tile background, keep border
        v.backgroundColor = .clear
        v.layer.cornerRadius = 10 // smaller radius
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        v.contentHorizontalAlignment = .fill
        v.contentVerticalAlignment = .fill
        v.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        // Icon (circular) on top
        let iconWrap = UIView()
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.backgroundColor = .systemTeal
        iconWrap.layer.cornerRadius = 18
        let icon = UIImageView(image: UIImage(systemName: systemImage))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        iconWrap.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
            iconWrap.widthAnchor.constraint(equalToConstant: 36),
            iconWrap.heightAnchor.constraint(equalToConstant: 36)
        ])

        // Title & subtitle under icon
        let t1 = UILabel()
        t1.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        t1.text = title
        t1.textAlignment = .left
        let t2 = UILabel()
        t2.font = UIFont.systemFont(ofSize: 12)
        t2.textColor = .secondaryLabel
        t2.text = subtitle
        t2.textAlignment = .left

        let vstack = UIStackView(arrangedSubviews: [iconWrap, t1, t2])
        vstack.axis = .vertical
        vstack.alignment = .leading
        vstack.spacing = 8
        vstack.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(vstack)
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
            // align approximately 30 from left edge as requested
            vstack.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 30),
            vstack.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -12),
            vstack.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -10)
        ])
        v.isUserInteractionEnabled = true
        v.isEnabled = true
        v.heightAnchor.constraint(greaterThanOrEqualToConstant: 84).isActive = true
        return v
    }

    @objc private func onTapTimeRange() {
        print("[Attachment] tap timeRange tile")
        showTimeRangeSheet()
    }

    @objc private func onTapAccount() {
        print("[Attachment] tap account tile")
        showAccountSheet()
    }

    // Present window-based sheets
    private func showTimeRangeSheet() {
        let content = TimeRangeSheetContent { [weak self] label in
            self?.onConfirm?(AttachmentContextItem(kind: .timeRange(label: label)))
        }
        FullscreenSheet.present(contentView: content)
    }

    private func showAccountSheet() {
        let accounts: [(String, String, String)] = [
            ("默认账户", "余额: ¥128,650", "普通账户"),
            ("教育金账户", "余额: ¥85,000", "子账户"),
            ("养老金账户", "余额: ¥256,000", "子账户")
        ]
        self.mockAccounts = accounts
        let content = AccountSheetContent(accounts: accounts) { [weak self] acc in
            self?.onConfirm?(AttachmentContextItem(kind: .account(name: acc.0, balance: acc.1, tag: acc.2)))
        }
        FullscreenSheet.present(contentView: content)
    }

    private func makeRecentRow(name: String, date: String, size: String) -> UIView {
        let btn = UIButton(type: .system)
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        let icon = UIImageView(image: UIImage(systemName: "doc.text"))
        icon.tintColor = .systemBlue
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 28).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 28).isActive = true
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.numberOfLines = 1
        let metaLabel = UILabel()
        metaLabel.text = "\(date) · \(size)"
        metaLabel.textColor = .secondaryLabel
        metaLabel.font = UIFont.systemFont(ofSize: 13)
        let textStack = UIStackView(arrangedSubviews: [nameLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.contentMode = .scaleAspectFit
        chevron.tintColor = .tertiaryLabel
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)
        let h = UIStackView(arrangedSubviews: [icon, textStack, chevron])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        h.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(h)
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: btn.topAnchor, constant: 12),
            h.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 12),
            h.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -12),
            h.bottomAnchor.constraint(equalTo: btn.bottomAnchor, constant: -12)
        ])
        chevron.widthAnchor.constraint(equalToConstant: 16).isActive = true
        chevron.heightAnchor.constraint(equalToConstant: 16).isActive = true
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
        btn.addAction(UIAction { [weak self] _ in
            self?.onConfirm?(AttachmentContextItem(kind: .recentFile(name: name, date: date, size: size)))
        }, for: .touchUpInside)
        return btn
    }

    @objc private func tapUpload() {
        onConfirm?(AttachmentContextItem(kind: .upload))
    }

}
