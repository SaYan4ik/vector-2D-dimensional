//
//  SideMenuTableViewCell.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 14.03.25.
//

import UIKit


class SideMenuTableViewCell: UITableViewCell {
    lazy var vectorCordsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "Vector"
        label.textColor = Themes.textPrimary
        return label
    }()
    
    lazy var vectorLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = "Length"
        label.textColor = Themes.textPrimary
        return label
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        stack.distribution = .fillEqually
        
        return stack
    }()
    
    let gradientLayer = CAGradientLayer()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutElements()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: self.layer)
        gradientLayer.frame = contentView.bounds
        
        let colorSet = [Themes.primaryBackgroundSecondary,
                        Themes.tintNavigationBar]
        let location = [0.2, 1.0]
        
        contentView.addGradient(with: gradientLayer, colorSet: colorSet, locations: location)
    }
    
    private func layoutElements() {
        layoutTitleLabel()
        layoutContainerView()
    }
    
    private func layoutTitleLabel() {
        containerStack.addArrangedSubview(vectorLengthLabel)
        containerStack.addArrangedSubview(vectorCordsLabel)
    }
    
    private func layoutContainerView() {
        self.contentView.addSubview(containerStack)
        contentView.layer.cornerRadius = 8
        
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            containerStack.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func set(vector: VectorModel) {
        let formedLength = String(format: "%.2f", vector.length)
        vectorLengthLabel.text = "Length: \(formedLength)"
        
        let formedStartX = String(format: "%.2f", vector.startX)
        let formedStartY = String(format: "%.2f", vector.startY)
        let formedEndX = String(format: "%.2f", vector.endX)
        let formedEndY = String(format: "%.2f", vector.endY)
        
        vectorCordsLabel.text = "(\(formedStartX), \(formedStartY))(\(formedEndX), \(formedEndY))"
    }
    
}

extension UIView {
    func addGradient(with layer: CAGradientLayer, gradientFrame: CGRect? = nil, colorSet: [UIColor],
                     locations: [Double], startEndPoints: (CGPoint, CGPoint)? = nil) {
        layer.frame = gradientFrame ?? self.bounds
        layer.frame.origin = .zero

        let layerColorSet = colorSet.map { $0.cgColor }
        let layerLocations = locations.map { $0 as NSNumber }

        layer.colors = layerColorSet
        layer.locations = layerLocations

        if let startEndPoints = startEndPoints {
            layer.startPoint = startEndPoints.0
            layer.endPoint = startEndPoints.1
        }

        self.layer.insertSublayer(layer, at: 0)
    }
}
