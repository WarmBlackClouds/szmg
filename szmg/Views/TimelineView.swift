//
//  TimelineView.swift
//  szmg
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

struct TimelineItem {
    let date: String
    let title: String
    let description: String
    let icon: String
    let color: UIColor
}

class TimelineView: UIView {
    
    // MARK: - Properties
    private let stackView = UIStackView()
    private var timelineItems: [TimelineItem] = []
    
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
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    // MARK: - Configuration
    func configure(items: [TimelineItem]) {
        timelineItems = items
        
        // Clear existing views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add timeline items
        for (index, item) in items.enumerated() {
            let itemView = createTimelineItemView(item: item, isLast: index == items.count - 1)
            stackView.addArrangedSubview(itemView)
        }
    }
    
    private func createTimelineItemView(item: TimelineItem, isLast: Bool) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Timeline line
        let timelineLineView = UIView()
        timelineLineView.backgroundColor = UIColor.systemGray4
        timelineLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(timelineLineView)
        
        // Timeline dot
        let dotView = UIView()
        dotView.backgroundColor = item.color
        dotView.layer.cornerRadius = 8
        dotView.layer.borderWidth = 3
        dotView.layer.borderColor = UIColor.systemBackground.cgColor
        dotView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dotView)
        
        // Icon
        let iconLabel = UILabel()
        iconLabel.text = item.icon
        iconLabel.font = UIFont.systemFont(ofSize: 12)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        dotView.addSubview(iconLabel)
        
        // Content card
        let contentCard = UIView()
        contentCard.backgroundColor = UIColor.systemBackground
        contentCard.layer.cornerRadius = 12
        contentCard.layer.shadowColor = UIColor.black.cgColor
        contentCard.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentCard.layer.shadowRadius = 4
        contentCard.layer.shadowOpacity = 0.1
        contentCard.layer.borderWidth = 1
        contentCard.layer.borderColor = UIColor.systemGray5.cgColor
        contentCard.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentCard)
        
        // Date label
        let dateLabel = UILabel()
        dateLabel.text = item.date
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(dateLabel)
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(titleLabel)
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = item.description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            // Timeline line (only show if not last item)
            timelineLineView.topAnchor.constraint(equalTo: dotView.bottomAnchor),
            timelineLineView.centerXAnchor.constraint(equalTo: dotView.centerXAnchor),
            timelineLineView.widthAnchor.constraint(equalToConstant: 2),
            timelineLineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            // Timeline dot
            dotView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dotView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dotView.widthAnchor.constraint(equalToConstant: 16),
            dotView.heightAnchor.constraint(equalToConstant: 16),
            
            // Icon in dot
            iconLabel.centerXAnchor.constraint(equalTo: dotView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: dotView.centerYAnchor),
            
            // Content card
            contentCard.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentCard.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 20),
            contentCard.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contentCard.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
            
            // Date label
            dateLabel.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),
            
            // Description label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -12),
        ])
        
        // Hide timeline line for last item
        if isLast {
            timelineLineView.isHidden = true
        }
        
        return containerView
    }
}

// MARK: - Feature Card View
class FeatureCardView: UIView {
    
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
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
        
        iconLabel.font = UIFont.systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }
    
    func configure(icon: String, title: String, description: String) {
        iconLabel.text = icon
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
