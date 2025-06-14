//
//  FloatingPanel.swift
//  szmg
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class FloatingPanel: UIView {
    
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var onSelectionChanged: ((Int) -> Void)?
    private var selectedIndex = 0
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Panel styling with gradient background
        setupGradientBackground()
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 8)
        layer.shadowRadius = 16
        layer.shadowOpacity = 0.3
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor

        // Title label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Stack view
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8 // Reduced spacing for better fit
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        setupConstraints()
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.9).cgColor,
            UIColor.systemPurple.withAlphaComponent(0.9).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 20
        layer.insertSublayer(gradientLayer, at: 0)

        // Store reference for layout updates
        layer.setValue(gradientLayer, forKey: "gradientLayer")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    // MARK: - Configuration
    func configure(title: String, options: [String], selectedIndex: Int = 0, onSelectionChanged: @escaping (Int) -> Void) {
        titleLabel.text = title
        self.selectedIndex = selectedIndex
        self.onSelectionChanged = onSelectionChanged
        
        // Clear existing buttons
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        // Create new buttons
        for (index, option) in options.enumerated() {
            let button = createOptionButton(title: option, index: index)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        updateButtonStates()
    }
    
    private func createOptionButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold) // Larger font
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.titleLabel?.numberOfLines = 2 // Allow 2 lines for better text display
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.tag = index
        button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateButtonStates() {
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                button.backgroundColor = .systemGray6
                button.setTitleColor(.systemBlue, for: .normal)
                button.layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
    }
    
    // MARK: - Actions
    @objc private func optionButtonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        
        selectedIndex = newIndex
        updateButtonStates()
        onSelectionChanged?(newIndex)
        
        // Animate selection
        UIView.animate(withDuration: 0.2) {
            sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
    }
    
    // MARK: - Public Methods
    func setSelectedIndex(_ index: Int) {
        guard index >= 0 && index < buttons.count else { return }
        selectedIndex = index
        updateButtonStates()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient layer frame
        if let gradientLayer = layer.value(forKey: "gradientLayer") as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }
}
