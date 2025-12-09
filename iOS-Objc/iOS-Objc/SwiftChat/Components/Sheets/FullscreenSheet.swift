import UIKit

@available(iOS 15.0, *)
final class FullscreenSheet: UIView {
    private static var current: FullscreenSheet?

    private let dimView = UIView()
    private let panel = UIView()
    private var panelBottomConstraint: NSLayoutConstraint?

    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        dimView.translatesAutoresizingMaskIntoConstraints = false
        // Darker dim background (less see-through)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        dimView.alpha = 0
        addSubview(dimView)

        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.backgroundColor = .secondarySystemBackground
        panel.layer.cornerRadius = 20
        if #available(iOS 11.0, *) {
            panel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        panel.layer.borderWidth = 1
        panel.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        addSubview(panel)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            panel.leadingAnchor.constraint(equalTo: leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        let bottom = panel.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottom.isActive = true
        panelBottomConstraint = bottom

        let tap = UITapGestureRecognizer(target: self, action: #selector(onDimTap))
        dimView.addGestureRecognizer(tap)
    }

    @objc private func onDimTap() { FullscreenSheet.dismiss() }

    func setContentView(_ v: UIView) {
        v.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: panel.topAnchor, constant: 12),
            v.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            v.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -12),
            // Keep content above the home indicator by using panel.safeAreaLayoutGuide
            v.bottomAnchor.constraint(equalTo: panel.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        layoutIfNeeded()
    }

    static func present(contentView: UIView) {
        guard current == nil else { return }
        guard let targetWindow = topMostWindow() else { return }
        let sheet = FullscreenSheet(frame: targetWindow.bounds)
        sheet.translatesAutoresizingMaskIntoConstraints = false
        targetWindow.addSubview(sheet)
        sheet.layer.zPosition = 9999
        targetWindow.bringSubviewToFront(sheet)
        NSLayoutConstraint.activate([
            sheet.topAnchor.constraint(equalTo: targetWindow.topAnchor),
            sheet.leadingAnchor.constraint(equalTo: targetWindow.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: targetWindow.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: targetWindow.bottomAnchor)
        ])
        sheet.setContentView(contentView)
        targetWindow.layoutIfNeeded()

        current = sheet
        UIView.animate(withDuration: 0.22) { sheet.dimView.alpha = 1 }
        sheet.panel.alpha = 0.0
        sheet.panel.transform = CGAffineTransform(translationX: 0, y: 40)
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            sheet.panel.alpha = 1.0
            sheet.panel.transform = .identity
        }
    }

    static func dismiss() {
        guard let sheet = current else { return }
        UIView.animate(withDuration: 0.2, animations: {
            sheet.dimView.alpha = 0
            sheet.panel.alpha = 0
            sheet.panel.transform = CGAffineTransform(translationX: 0, y: 40)
        }, completion: { _ in
            sheet.removeFromSuperview()
            current = nil
        })
    }

    private static func topMostWindow() -> UIWindow? {
        // Prefer the highest-level visible window
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .filter { !$0.isHidden && $0.alpha > 0.0 }
        return windows.sorted(by: { $0.windowLevel.rawValue < $1.windowLevel.rawValue }).last
    }
}
