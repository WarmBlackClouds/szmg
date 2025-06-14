//
//  TrendChartView.swift
//  szmg
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class TrendChartView: UIView {
    
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let chartView = UIView()
    private let lineLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let pointLayers: [CAShapeLayer] = []
    
    private var dataPoints: [CGFloat] = []
    private var maxValue: CGFloat = 100
    
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
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        // Title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Chart view
        chartView.backgroundColor = .clear
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)
        
        // Line layer
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.lineWidth = 3
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        chartView.layer.addSublayer(lineLayer)
        
        // Gradient layer
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.3).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        chartView.layer.insertSublayer(gradientLayer, below: lineLayer)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            chartView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateChart()
    }
    
    // MARK: - Configuration
    func configure(title: String, dataPoints: [CGFloat], maxValue: CGFloat? = nil) {
        titleLabel.text = title
        self.dataPoints = dataPoints
        self.maxValue = maxValue ?? dataPoints.max() ?? 100
        updateChart()
    }
    
    private func updateChart() {
        guard !dataPoints.isEmpty, chartView.bounds.width > 0, chartView.bounds.height > 0 else { return }
        
        let path = UIBezierPath()
        let fillPath = UIBezierPath()
        
        let width = chartView.bounds.width
        let height = chartView.bounds.height
        let stepX = width / CGFloat(dataPoints.count - 1)
        
        // Create line path
        for (index, value) in dataPoints.enumerated() {
            let x = CGFloat(index) * stepX
            let y = height - (value / maxValue) * height
            let point = CGPoint(x: x, y: y)
            
            if index == 0 {
                path.move(to: point)
                fillPath.move(to: CGPoint(x: x, y: height))
                fillPath.addLine(to: point)
            } else {
                path.addLine(to: point)
                fillPath.addLine(to: point)
            }
        }
        
        // Complete fill path
        fillPath.addLine(to: CGPoint(x: width, y: height))
        fillPath.close()
        
        // Update layers
        lineLayer.path = path.cgPath

        // Create a mask layer for the gradient
        let maskLayer = CAShapeLayer()
        maskLayer.path = fillPath.cgPath
        gradientLayer.mask = maskLayer
        gradientLayer.frame = chartView.bounds
        
        // Animate line drawing
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lineLayer.add(animation, forKey: "lineAnimation")
    }
}

// MARK: - Statistics Summary Card
class StatisticsSummaryCard: UIView {
    
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let changeLabel = UILabel()
    private let trendImageView = UIImageView()
    
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
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        iconLabel.font = UIFont.systemFont(ofSize: 32)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 2 // Allow 2 lines for better text display
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        valueLabel.font = UIFont.boldSystemFont(ofSize: 24)
        valueLabel.textColor = .label
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        changeLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(changeLabel)
        
        trendImageView.contentMode = .scaleAspectFit
        trendImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trendImageView)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconLabel.widthAnchor.constraint(equalToConstant: 40),
            iconLabel.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 32), // Ensure minimum height for 2 lines

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            trendImageView.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor),
            trendImageView.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 8),
            trendImageView.widthAnchor.constraint(equalToConstant: 16),
            trendImageView.heightAnchor.constraint(equalToConstant: 16),
            
            changeLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            changeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            changeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
    
    func configure(icon: String, title: String, value: String, change: String? = nil, isPositive: Bool = true) {
        iconLabel.text = icon
        titleLabel.text = title
        valueLabel.text = value
        
        if let change = change {
            changeLabel.text = change
            changeLabel.textColor = isPositive ? .systemGreen : .systemRed
            
            // Set trend arrow
            let arrowImage = UIImage(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
            trendImageView.image = arrowImage
            trendImageView.tintColor = isPositive ? .systemGreen : .systemRed
            
            changeLabel.isHidden = false
            trendImageView.isHidden = false
        } else {
            changeLabel.isHidden = true
            trendImageView.isHidden = true
        }
    }
}
