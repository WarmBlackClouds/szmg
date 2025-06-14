//
//  TabController.swift
//  szmg
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class TabController: UIView {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let indicatorView = UIView()
    private var tabButtons: [UIButton] = []
    private var onTabChanged: ((Int) -> Void)?
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
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        // Scroll view for tabs
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        // Stack view for tab buttons
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Indicator view
        indicatorView.backgroundColor = .systemBlue
        indicatorView.layer.cornerRadius = 2
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            // Indicator view constraints
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
        ])
    }
    
    // MARK: - Configuration
    func configure(tabs: [String], onTabChanged: @escaping (Int) -> Void) {
        self.onTabChanged = onTabChanged
        
        // Clear existing tabs
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        
        // Create tab buttons
        for (index, title) in tabs.enumerated() {
            let button = createTabButton(title: title, index: index)
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        // Update stack view width constraint
        if !tabs.isEmpty {
            stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
        
        updateTabAppearance()
        updateIndicatorPosition()
    }
    
    private func createTabButton(title: String, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.tag = index
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    private func updateTabAppearance() {
        for (index, button) in tabButtons.enumerated() {
            if index == selectedIndex {
                button.setTitleColor(.systemBlue, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            } else {
                button.setTitleColor(.secondaryLabel, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            }
        }
    }
    
    private func updateIndicatorPosition() {
        guard selectedIndex < tabButtons.count else { return }
        
        let selectedButton = tabButtons[selectedIndex]
        
        // Remove existing indicator constraints
        indicatorView.removeFromSuperview()
        addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            indicatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
            indicatorView.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor, constant: 16),
            indicatorView.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor, constant: -16),
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.layoutIfNeeded()
        })
    }
    
    // MARK: - Actions
    @objc private func tabButtonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        guard newIndex != selectedIndex else { return }
        
        selectedIndex = newIndex
        updateTabAppearance()
        updateIndicatorPosition()
        onTabChanged?(newIndex)
    }
    
    // MARK: - Public Methods
    func setSelectedIndex(_ index: Int) {
        guard index >= 0 && index < tabButtons.count else { return }
        selectedIndex = index
        updateTabAppearance()
        updateIndicatorPosition()
    }
}

// MARK: - Tab Content View
class TabContentView: UIView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    func addContent(_ view: UIView) {
        contentView.addSubview(view)
    }
    
    func clearContent() {
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    var content: UIView {
        return contentView
    }
}
