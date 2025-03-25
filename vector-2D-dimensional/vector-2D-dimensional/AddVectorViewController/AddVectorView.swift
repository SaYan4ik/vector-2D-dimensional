//
//  AddVectorView.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 18.03.25.
//

import UIKit
import Combine


final class AddVectorView: UIView {
    lazy var mainContainerStack = stackViewBuilder(axis: .vertical,
                                                   distribution: .fill,
                                                   spacing: 8)
    
    lazy var startVectorLabelCords = createLabel(text: "Start cords X / Y",
                                                 font: .boldSystemFont(ofSize: 17))
    
    lazy var endVectorLabelCords = createLabel(text: "End cords X / Y",
                                               font: .boldSystemFont(ofSize: 17))
    
    lazy var otherParamsLabel = createLabel(text: "Length / Degree",
                                            font: .boldSystemFont(ofSize: 17))
    
    lazy var startContainerStack = stackViewBuilder(axis: .horizontal,
                                                    distribution: .fillEqually,
                                                    spacing: 5)
    
    lazy var startXTextField = textFieldBuilderForCords(with: "Start X")
    lazy var startYTextField = textFieldBuilderForCords(with: "Start Y")
    
    lazy var endContainerStack = stackViewBuilder(axis: .horizontal,
                                                  distribution: .fillEqually,
                                                  spacing: 5)
    
    lazy var endXTextField = textFieldBuilderForCords(with: "End X")
    lazy var endYTextField = textFieldBuilderForCords(with: "End Y")
    
    lazy var otherParamsContainerStack = stackViewBuilder(axis: .horizontal,
                                                          distribution: .fillEqually,
                                                          spacing: 5)
    
    lazy var lengthTextField = textFieldBuilderForCords(with: "Length")
    lazy var angleTextField = textFieldBuilderForCords(with: "Degree")
    private(set) var isEditing = false
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLabel(text: String,
                             font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func textFieldBuilderForCords(with placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.backgroundColor = Themes.tintNavigationBar.withAlphaComponent(0.8)
        textField.textColor = .black
        textField.layer.cornerRadius = 6
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        textField.keyboardType = .decimalPad
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)
        textField.setContentHuggingPriority(.required, for: .horizontal)
        return textField
    }
    
    private func stackViewBuilder(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution ,spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.alignment = .fill
        stackView.distribution = distribution
        return stackView
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(mainContainerStack)
        
        mainContainerStack.addArrangedSubview(startVectorLabelCords)
        mainContainerStack.addArrangedSubview(startContainerStack)
        startContainerStack.addArrangedSubview(startXTextField)
        startContainerStack.addArrangedSubview(startYTextField)
        
        mainContainerStack.addArrangedSubview(endVectorLabelCords)
        mainContainerStack.addArrangedSubview(endContainerStack)
        endContainerStack.addArrangedSubview(endXTextField)
        endContainerStack.addArrangedSubview(endYTextField)
        
        mainContainerStack.addArrangedSubview(otherParamsLabel)
        mainContainerStack.addArrangedSubview(otherParamsContainerStack)
        otherParamsContainerStack.addArrangedSubview(lengthTextField)
        otherParamsContainerStack.addArrangedSubview(angleTextField)
        
        NSLayoutConstraint.activate([
            mainContainerStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainContainerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainContainerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainContainerStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
}

extension UITextField {
  func textPublisher() -> AnyPublisher<String, Never> {
      NotificationCenter.default
          .publisher(for: UITextField.textDidChangeNotification, object: self)
          .map { ($0.object as? UITextField)?.text  ?? "" }
          .eraseToAnyPublisher()
  }
}
