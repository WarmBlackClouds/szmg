//
//  CircularProgressView.swift
//  szmg
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class CircularProgressView: UIView {
    
    // MARK: - Properties
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let centerLabel = UILabel()
    private let titleLabel = UILabel()
    
    private var progress: Float = 0.0
    
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
        backgroundColor = .clear
        
        // Track layer (background circle)
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 8
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        // Progress layer
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
        // Center label
        centerLabel.textAlignment = .center
        centerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        centerLabel.textColor = .label
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerLabel)
        
        // Title label
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            
            titleLabel.topAnchor.constraint(equalTo: centerLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 10
        
        let circularPath = UIBezierPath(arcCenter: center,
                                       radius: radius,
                                       startAngle: -CGFloat.pi / 2,
                                       endAngle: 3 * CGFloat.pi / 2,
                                       clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    // MARK: - Configuration
    func configure(title: String, value: String, progress: Float, color: UIColor = .systemBlue) {
        titleLabel.text = title
        centerLabel.text = value
        self.progress = progress
        progressLayer.strokeColor = color.cgColor
        
        // Animate progress
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = progress
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer.strokeEnd = CGFloat(progress)
        progressLayer.add(animation, forKey: "progressAnimation")
    }
    
    func updateProgress(_ newProgress: Float, animated: Bool = true) {
        let oldProgress = progress
        progress = newProgress
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = oldProgress
            animation.toValue = newProgress
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressUpdate")
        }
        
        progressLayer.strokeEnd = CGFloat(newProgress)
    }
}

// MARK: - Achievement Badge View
class AchievementBadgeView: UIView {
    
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let progressView = UIProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        iconLabel.font = UIFont.systemFont(ofSize: 32)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 2
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            iconLabel.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            progressView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 4),
        ])
    }
    
    func configure(icon: String, title: String, description: String, progress: Float, isUnlocked: Bool = false) {
        iconLabel.text = icon
        titleLabel.text = title
        descriptionLabel.text = description
        progressView.progress = progress
        
        if isUnlocked {
            backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            layer.borderColor = UIColor.systemGreen.cgColor
            progressView.progressTintColor = .systemGreen
        } else {
            backgroundColor = UIColor.systemBackground
            layer.borderColor = UIColor.systemGray5.cgColor
            progressView.progressTintColor = .systemBlue
        }
    }
}
