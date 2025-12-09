//
//  AccountOpeningCardView.swift
//  MyFA
//
//  Account opening process card component
//

import UIKit

@objc public class AccountOpeningCardView: UIView {
    
    private let steps: [String]
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let stepsStackView = UIStackView()
    
    @objc public init(steps: [String]) {
        self.steps = steps
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Container
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(white: 0.25, alpha: 1.0).cgColor
        addSubview(containerView)
        
        // Title
        titleLabel.text = LocalizationHelper.localized("assets.opening.title")
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .lightGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Steps stack
        stepsStackView.axis = .vertical
        stepsStackView.spacing = 12
        stepsStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stepsStackView)
        
        for (index, step) in steps.enumerated() {
            let stepView = createStepView(number: index + 1, text: step)
            stepsStackView.addArrangedSubview(stepView)
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            stepsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stepsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stepsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stepsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createStepView(number: Int, text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let numberLabel = UILabel()
        numberLabel.text = "\(number)"
        numberLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        numberLabel.layer.cornerRadius = 14
        numberLabel.clipsToBounds = true
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = .white
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(numberLabel)
        container.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 28),
            numberLabel.heightAnchor.constraint(equalToConstant: 28),
            
            textLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 12),
            textLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        return container
    }
}

