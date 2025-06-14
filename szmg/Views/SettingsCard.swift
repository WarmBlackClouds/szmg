//
//  SettingsCard.swift
//  szmg
//
//  Created by AI Assistant on 2025/1/10.
//

import UIKit

class SettingsCard: UIView {
    
    // MARK: - Properties
    private let titleLabel = UILabel()
    private let iconLabel = UILabel()
    private let stackView = UIStackView()
    
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
        // Card styling
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.1
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        
        // Icon label
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)
        
        // Title label
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Stack view for settings items
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Icon constraints
            iconLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Title constraints
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: - Configuration
    func configure(icon: String, title: String) {
        iconLabel.text = icon
        titleLabel.text = title
    }
    
    func addSettingItem(_ item: UIView) {
        stackView.addArrangedSubview(item)
    }
    
    func clearItems() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

// MARK: - Setting Item Views
class SettingSwitchItem: UIView {
    private let label = UILabel()
    private let switchControl = UISwitch()
    private var onValueChanged: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 8
        
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        switchControl.onTintColor = .systemBlue
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),
            
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    func configure(title: String, isOn: Bool, onValueChanged: @escaping (Bool) -> Void) {
        label.text = title
        switchControl.isOn = isOn
        self.onValueChanged = onValueChanged
    }
    
    @objc private func switchValueChanged() {
        onValueChanged?(switchControl.isOn)
    }
}

class SettingSliderItem: UIView {
    private let label = UILabel()
    private let slider = UISlider()
    private let valueLabel = UILabel()
    private var onValueChanged: ((Float) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 8
        
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.tintColor = .systemBlue
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        addSubview(slider)
        
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60),
            
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            slider.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -8),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            valueLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            valueLabel.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    func configure(title: String, value: Float, onValueChanged: @escaping (Float) -> Void) {
        label.text = title
        slider.value = value
        valueLabel.text = "\(Int(value * 100))%"
        self.onValueChanged = onValueChanged
    }
    
    @objc private func sliderValueChanged() {
        valueLabel.text = "\(Int(slider.value * 100))%"
        onValueChanged?(slider.value)
    }
}

class SettingButtonItem: UIView {
    private let button = UIButton(type: .system)
    private var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),
            
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configure(title: String, color: UIColor, onTap: @escaping () -> Void) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        self.onTap = onTap
    }
    
    @objc private func buttonTapped() {
        onTap?()
    }
}
