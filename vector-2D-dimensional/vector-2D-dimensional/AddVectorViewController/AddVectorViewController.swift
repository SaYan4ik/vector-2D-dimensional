//
//  AddVectorViewController.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import UIKit
import Combine


class AddVectorViewController: UIViewController {
    private var viewModel: CanvasViewModel
    
    private var addVectorView: AddVectorView = {
        let view = AddVectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var saveButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(
            "Save",
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    init(viewModel: CanvasViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    private func setupUI()  {
        view.backgroundColor = Themes.primaryBackground
        
        view.addSubview(addVectorView)
        NSLayoutConstraint.activate([
            addVectorView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            addVectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addVectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addVectorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc private func saveButtonTapped() {
        guard let startX = Double(addVectorView.startXTextField.text ?? ""),
              let startY = Double(addVectorView.startYTextField.text ?? ""),
              let endX = Double(addVectorView.endXTextField.text ?? ""),
              let endY = Double(addVectorView.endYTextField.text ?? ""),
              let length = Double(addVectorView.lengthTextField.text ?? ""),
              let angle = Double(addVectorView.angleTextField.text ?? "")
        else {
            return
        }
        
        let randomColor = UIColor (
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
        
        viewModel.addVector(
            startX: startX,
            startY: startY,
            endX: endX,
            endY: endY,
            color: randomColor,
            length: length,
            angle: angle
        )
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapClose() {
        navigationController?.popViewController(animated: true)
    }
    
}

class AddVectorView: UIView {
    lazy var mainContainerStack = stackViewBuilder(axis: .vertical,
                                                   distribution: .fill,
                                                   spacing: 8)
    
    lazy var startVectorLabelCords = createLabel(text: "Start cords X / Y",
                                                 font: .boldSystemFont(ofSize: 17))
    
    lazy var endVectorLabelCords = createLabel(text: "End cords X / Y",
                                               font: .boldSystemFont(ofSize: 17))
    
    lazy var otherParamsLabel = createLabel(text: "Other Params",
                                            font: .boldSystemFont(ofSize: 17))
    
    lazy var startContainerStack = stackViewBuilder(axis: .horizontal,
                                                    distribution: .fillProportionally,
                                                    spacing: 5)
    
    lazy var startXTextField = textFieldBuilderForCords(with: "Start X")
    lazy var startYTextField = textFieldBuilderForCords(with: "Start Y")
    
    lazy var endContainerStack = stackViewBuilder(axis: .horizontal,
                                                  distribution: .fillProportionally,
                                                  spacing: 5)
    
    lazy var endXTextField = textFieldBuilderForCords(with: "End X")
    lazy var endYTextField = textFieldBuilderForCords(with: "End Y")
    
    lazy var otherParamsContainerStack = stackViewBuilder(axis: .horizontal,
                                                          distribution: .fillProportionally,
                                                          spacing: 5)
    
    lazy var lengthTextField = textFieldBuilderForCords(with: "Length")
    lazy var angleTextField = textFieldBuilderForCords(with: "Degree")
    
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
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.cornerRadius = 6
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        textField.keyboardType = .decimalPad
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
        
        startXTextField.delegate = self
        startYTextField.delegate = self
        endXTextField.delegate = self
        endYTextField.delegate = self
        lengthTextField.delegate = self
        angleTextField.delegate = self
    }
    
    private func updateFields() {
        guard let startX = Double(startXTextField.text ?? "0"),
              let startY = Double(startYTextField.text ?? "0"),
              let endX = Double(endXTextField.text ?? "0"),
              let endY = Double(endYTextField.text ?? "0") else {
            return
        }
        
        let dx = endX - startX
        let dy = endY - startY
        let length = sqrt(dx * dx + dy * dy)
        lengthTextField.text = String(format: "%.2f", length)
        
        let angle = atan2(dy, dx) * 180 / .pi
        angleTextField.text = String(format: "%.2f", angle)
    }
    
    private func updateCoordinatesFromLengthAndAngle() {
        guard let startX = Double(startXTextField.text ?? "0"),
              let startY = Double(startYTextField.text ?? "0"),
              let length = Double(lengthTextField.text ?? "0"),
              let angle = Double(angleTextField.text ?? "0") else {
            return
        }
        
        let radians = angle * .pi / 180
        
        let endX = startX + length * cos(radians)
        let endY = startY + length * sin(radians)
        
        endXTextField.text = String(format: "%.2f", endX)
        endYTextField.text = String(format: "%.2f", endY)
    }
}

extension AddVectorView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == lengthTextField || textField == angleTextField {
            updateCoordinatesFromLengthAndAngle()
        } else {
            updateFields()
        }
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

