//
//  CircularMenuButton.swift
//  szmg
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class CircularMenuButton: UIView {
    
    // MARK: - Properties
    private let button = UIButton(type: .system)
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let pulseLayer = CAShapeLayer()
    private var onTap: (() -> Void)?
    
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
        // Container setup - optimized for 100x100 size
        backgroundColor = UIColor.white.withAlphaComponent(0.95)
        layer.cornerRadius = 20 // Larger corner radius for bigger buttons
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3

        // Icon label - larger for 100x100 button
        iconLabel.font = UIFont.systemFont(ofSize: 36)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)

        // Title label - optimized for larger button size
        titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2 // Allow up to 2 lines for better text display
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Button overlay
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)

        setupConstraints()
        setupPulseAnimation()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Icon constraints - optimized for 100x100 button
            iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconLabel.heightAnchor.constraint(equalToConstant: 40),

            // Title constraints - more space for 2-line text
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10),

            // Button constraints
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func setupPulseAnimation() {
        pulseLayer.strokeColor = UIColor.systemBlue.cgColor
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.lineWidth = 3
        pulseLayer.opacity = 0
        layer.addSublayer(pulseLayer)
    }
    
    // MARK: - Configuration
    func configure(icon: String, title: String, color: UIColor, onTap: @escaping () -> Void) {
        iconLabel.text = icon
        titleLabel.text = title
        iconLabel.textColor = color
        self.onTap = onTap
        
        // Update pulse color
        pulseLayer.strokeColor = color.cgColor
    }
    
    // MARK: - Actions
    @objc private func buttonTapped() {
        animatePress()
        onTap?()
    }
    
    private func animatePress() {
        // Scale animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
        
        // Pulse animation
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 0.8
        pulseAnimation.toValue = 0
        pulseAnimation.duration = 0.6
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.3
        scaleAnimation.duration = 0.6
        
        pulseLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        pulseLayer.add(pulseAnimation, forKey: "opacity")
        pulseLayer.add(scaleAnimation, forKey: "scale")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        // Keep rounded rectangle shape optimized for larger buttons
        layer.cornerRadius = 20
        pulseLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }
}
