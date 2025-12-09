import UIKit

@available(iOS 15.0, *)
final class TimeRangeSheetContent: UIView {
    private let onSelect: (String) -> Void

    init(onSelect: @escaping (String) -> Void) {
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
        title.text = "时间范围"
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

        let grid = UIStackView()
        grid.axis = .vertical
        grid.alignment = .fill
        grid.spacing = 12
        grid.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grid)

        func makeChoice(_ label: String) -> UIButton {
            let b = UIButton(type: .system)
            b.setTitle(label, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            b.setTitleColor(.label, for: .normal)
            b.backgroundColor = .tertiarySystemBackground
            b.layer.cornerRadius = 14
            b.layer.borderWidth = 1
            b.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
            b.heightAnchor.constraint(equalToConstant: 56).isActive = true
            b.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }
                self.onSelect(label)
                FullscreenSheet.dismiss()
            }, for: .touchUpInside)
            return b
        }

        let row1 = UIStackView(arrangedSubviews: [makeChoice("近1个月"), makeChoice("近3个月")])
        row1.axis = .horizontal; row1.spacing = 12; row1.distribution = .fillEqually
        let row2 = UIStackView(arrangedSubviews: [makeChoice("近6个月"), makeChoice("近1年")])
        row2.axis = .horizontal; row2.spacing = 12; row2.distribution = .fillEqually
        grid.addArrangedSubview(row1)
        grid.addArrangedSubview(row2)

        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            closeBtn.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            title.centerXAnchor.constraint(equalTo: centerXAnchor),
            title.centerYAnchor.constraint(equalTo: closeBtn.centerYAnchor),

            sep.topAnchor.constraint(equalTo: closeBtn.bottomAnchor, constant: 12),
            sep.leadingAnchor.constraint(equalTo: leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: trailingAnchor),
            sep.heightAnchor.constraint(equalToConstant: 1),

            grid.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: 16),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            grid.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
