//
//  StrategyCardView.swift
//  MyFA
//
//  Reusable strategy card component
//

import UIKit

@objc public class StrategyCardView: UIView {
    
    private let strategy: Strategy
    @objc public weak var delegate: StrategyCardDelegate?
    
    private let containerView = UIView()
    private let creatorAvatarView = UIView()
    private let creatorNameLabel = UILabel()
    private let creatorRoleLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let chartView: PerformanceChartView
    private let metricsStackView = UIStackView()
    private let tagsStackView = UIStackView()
    private let engagementStackView = UIStackView()
    private let returnBadge = UILabel()
    private let takeToChatButton = UIButton(type: .system)
    private let followButton = UIButton(type: .system)
    
    @objc public init(strategy: Strategy) {
        self.strategy = strategy
        self.chartView = PerformanceChartView(dataPoints: strategy.historicalData)
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        containerView.layer.cornerRadius = 12
        addSubview(containerView)
        
        // Creator avatar
        creatorAvatarView.translatesAutoresizingMaskIntoConstraints = false
        creatorAvatarView.backgroundColor = UIColor(hex: strategy.creator.avatarColor)
        creatorAvatarView.layer.cornerRadius = 20
        
        let avatarLabel = UILabel()
        avatarLabel.text = String(strategy.creator.name.prefix(1))
        avatarLabel.textColor = .white
        avatarLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        creatorAvatarView.addSubview(avatarLabel)
        
        // Creator info
        creatorNameLabel.text = strategy.creator.name
        creatorNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        creatorNameLabel.textColor = .white
        creatorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        creatorRoleLabel.text = strategy.creator.role
        creatorRoleLabel.font = .systemFont(ofSize: 12)
        creatorRoleLabel.textColor = .gray
        creatorRoleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Return badge
        returnBadge.text = String(format: "+%.1f%%", strategy.performance.annualReturn)
        returnBadge.font = .systemFont(ofSize: 14, weight: .semibold)
        returnBadge.textColor = UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0)
        returnBadge.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 0.3)
        returnBadge.layer.cornerRadius = 12
        returnBadge.clipsToBounds = true
        returnBadge.textAlignment = .center
        returnBadge.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        titleLabel.text = strategy.title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Description
        descriptionLabel.text = strategy.desc
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 3
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Chart
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        // Tags
        setupTags()
        
        // Metrics
        setupMetrics()
        
        // Engagement
        setupEngagement()
        
        // Buttons
        setupButtons()
        
        // Layout
        containerView.addSubview(creatorAvatarView)
        containerView.addSubview(creatorNameLabel)
        containerView.addSubview(creatorRoleLabel)
        containerView.addSubview(returnBadge)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(chartView)
        containerView.addSubview(metricsStackView)
        containerView.addSubview(tagsStackView)
        containerView.addSubview(engagementStackView)
        containerView.addSubview(takeToChatButton)
        containerView.addSubview(followButton)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Avatar
            creatorAvatarView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            creatorAvatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            creatorAvatarView.widthAnchor.constraint(equalToConstant: 40),
            creatorAvatarView.heightAnchor.constraint(equalToConstant: 40),
            
            avatarLabel.centerXAnchor.constraint(equalTo: creatorAvatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: creatorAvatarView.centerYAnchor),
            
            // Creator name
            creatorNameLabel.leadingAnchor.constraint(equalTo: creatorAvatarView.trailingAnchor, constant: 12),
            creatorNameLabel.topAnchor.constraint(equalTo: creatorAvatarView.topAnchor, constant: 4),
            
            // Creator role
            creatorRoleLabel.leadingAnchor.constraint(equalTo: creatorNameLabel.leadingAnchor),
            creatorRoleLabel.topAnchor.constraint(equalTo: creatorNameLabel.bottomAnchor, constant: 2),
            
            // Return badge
            returnBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            returnBadge.centerYAnchor.constraint(equalTo: creatorAvatarView.centerYAnchor),
            returnBadge.widthAnchor.constraint(equalToConstant: 80),
            returnBadge.heightAnchor.constraint(equalToConstant: 24),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: creatorAvatarView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Description (truncated for brevity - would continue with full constraints)
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Chart
            chartView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 80),
            
            // Metrics
            metricsStackView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 16),
            metricsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            metricsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Tags
            tagsStackView.topAnchor.constraint(equalTo: metricsStackView.bottomAnchor, constant: 12),
            tagsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            // Engagement
            engagementStackView.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 12),
            engagementStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            engagementStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Buttons
            takeToChatButton.topAnchor.constraint(equalTo: engagementStackView.bottomAnchor, constant: 16),
            takeToChatButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            takeToChatButton.trailingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -8),
            takeToChatButton.heightAnchor.constraint(equalToConstant: 44),
            takeToChatButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            followButton.topAnchor.constraint(equalTo: takeToChatButton.topAnchor),
            followButton.leadingAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 8),
            followButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            followButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupTags() {
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for tag in strategy.tags {
            let tagLabel = createTagLabel(text: tag.text, type: tag.type)
            tagsStackView.addArrangedSubview(tagLabel)
        }
    }
    
    private func createTagLabel(text: String, type: Strategy.Tag.TagType) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch type {
        case .risk:
            label.backgroundColor = UIColor(red: 0.6, green: 0.3, blue: 0.3, alpha: 0.3)
        case .term:
            label.backgroundColor = UIColor(red: 0.3, green: 0.4, blue: 0.6, alpha: 0.3)
        case .asset:
            label.backgroundColor = UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 0.3)
        }
        
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        return label
    }
    
    private func setupMetrics() {
        metricsStackView.axis = .horizontal
        metricsStackView.distribution = .fillEqually
        metricsStackView.spacing = 12
        metricsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let metrics = [
            (LocalizationHelper.localized("strategies.annual.return"), String(format: "+%.1f%%", strategy.performance.annualReturn)),
            (LocalizationHelper.localized("strategies.max.drawdown"), String(format: "%.1f%%", strategy.performance.maxDrawdown)),
            (LocalizationHelper.localized("strategies.sharpe.ratio"), String(format: "%.2f", strategy.performance.sharpeRatio)),
            (LocalizationHelper.localized("strategies.win.rate"), String(format: "%.0f%%", strategy.performance.winRate))
        ]
        
        for (label, value) in metrics {
            let metricView = createMetricView(label: label, value: value)
            metricsStackView.addArrangedSubview(metricView)
        }
    }
    
    private func createMetricView(label: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = .gray
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLabel.textColor = value.hasPrefix("+") ?
            UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0) :
            (value.hasPrefix("-") ? UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0) : .white)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupEngagement() {
        engagementStackView.axis = .horizontal
        engagementStackView.spacing = 16
        engagementStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Likes
        let likesLabel = createEngagementLabel(icon: "heart", count: strategy.engagement.likes)
        engagementStackView.addArrangedSubview(likesLabel)
        
        // Comments
        let commentsLabel = createEngagementLabel(icon: "message", count: strategy.engagement.comments)
        engagementStackView.addArrangedSubview(commentsLabel)
        
        // Followers
        let followersIcon = UIImageView(image: UIImage(systemName: "person.2"))
        followersIcon.tintColor = .gray
        followersIcon.translatesAutoresizingMaskIntoConstraints = false
        followersIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        let followersLabel = UILabel()
        followersLabel.text = String(format: LocalizationHelper.localized("strategies.recent.followers"), strategy.engagement.recentFollowers)
        followersLabel.font = .systemFont(ofSize: 12)
        followersLabel.textColor = .gray
        followersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        engagementStackView.addArrangedSubview(followersIcon)
        engagementStackView.addArrangedSubview(followersLabel)
        engagementStackView.addArrangedSubview(spacer)
    }
    
    private func createEngagementLabel(icon: String, count: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .gray
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "\(count)"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        return container
    }
    
    private func setupButtons() {
        // Take to Chat button
        takeToChatButton.setTitle(LocalizationHelper.localized("strategies.take.to.chat"), for: .normal)
        takeToChatButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        takeToChatButton.setTitleColor(.white, for: .normal)
        takeToChatButton.backgroundColor = UIColor(red: 0.46, green: 0.42, blue: 1.00, alpha: 1.00)
        takeToChatButton.layer.cornerRadius = 8
        takeToChatButton.translatesAutoresizingMaskIntoConstraints = false
        takeToChatButton.addTarget(self, action: #selector(takeToChatTapped), for: .touchUpInside)
        
        // Follow button
        followButton.setTitle(LocalizationHelper.localized("strategies.follow"), for: .normal)
        followButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        followButton.setTitleColor(.white, for: .normal)
        followButton.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        followButton.layer.cornerRadius = 8
        followButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func takeToChatTapped() {
        delegate?.strategyCardDidTapTakeToChat(self, strategy: strategy)
    }
}

@objc public protocol StrategyCardDelegate: AnyObject {
    func strategyCardDidTapTakeToChat(_ card: StrategyCardView, strategy: Strategy)
}

// Helper extension for hex colors
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

