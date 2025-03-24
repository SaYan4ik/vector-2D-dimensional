//
//  AddVectorViewController.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import UIKit
import Combine


final class AddVectorViewController: UIViewController {
    private var viewModel = AddVectorViewModel()
    private var cancellables = Set<AnyCancellable>()
    var vectorDidAdd: ((VectorModel) -> Void)?
    
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
        
        button.setTitleColor(
            Themes.tintNavigationBar,
            for: .normal
        )
        
        button.addTarget(
            self,
            action: #selector(saveButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    init(viewModel: AddVectorViewModel) {
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
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$startX
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                
                self.addVectorView.startXTextField.text = String(format: "%.2f", value)
            }.store(in: &cancellables)
        
        viewModel.$startY
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                
                self.addVectorView.startYTextField.text = String(format: "%.2f", value)
            }.store(in: &cancellables)
        
        viewModel.$endX
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                
                self.addVectorView.endXTextField.text = String(format: "%.2f", value)
            }.store(in: &cancellables)
        
        viewModel.$endY
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                
                self.addVectorView.endYTextField.text = String(format: "%.2f", value)
            }.store(in: &cancellables)
        
        viewModel.$length
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                
                self.addVectorView.lengthTextField.text = String(format: "%.2f", value)
            }.store(in: &cancellables)
        
        viewModel.$angle
            .removeDuplicates()
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self else { return }
                
                self.addVectorView.angleTextField.text = String(format: "%.2f", value)
            }.store(in: &cancellables)
        
        addVectorView.startXTextField.textPublisher()
            .sink { [weak self] value in
                guard let self,
                      let numericValue = Double(value)
                else { return }
                
                
                self.viewModel.updateCoordinates(startX: numericValue,
                                                 startY: self.viewModel.startY,
                                                 endX: self.viewModel.endX,
                                                 endY: self.viewModel.endY
                )
            }.store(in: &cancellables)
        
        addVectorView.startYTextField.textPublisher()
            .sink { [weak self] value in
                guard let self,
                      let numericValue = Double(value)
                else { return }
                
                self.viewModel.updateCoordinates(startX: self.viewModel.startX,
                                                 startY: numericValue,
                                                 endX: self.viewModel.endX,
                                                 endY: self.viewModel.endY
                )
            }.store(in: &cancellables)
        
        addVectorView.endXTextField.textPublisher()
            .sink { [weak self] value in
                guard let self,
                      let numericValue = Double(value)
                else { return }
                
                self.viewModel.updateCoordinates(startX: self.viewModel.startX,
                                                 startY: self.viewModel.startY,
                                                 endX: numericValue,
                                                 endY: self.viewModel.endY
                )
            }.store(in: &cancellables)
        
        addVectorView.endYTextField.textPublisher()
            .sink { [weak self] value in
                guard let self,
                      let numericValue = Double(value)
                else { return }
                
                self.viewModel.updateCoordinates(startX: self.viewModel.startX,
                                                 startY: self.viewModel.startY,
                                                 endX: self.viewModel.endX,
                                                 endY: numericValue
                )
            }.store(in: &cancellables)
        
        addVectorView.lengthTextField.textPublisher()
            .sink { [weak self] value in
                guard let self,
                      let numericValue = Double(value)
                else { return }
                
                self.viewModel.updateLengthAndAngle(startX: self.viewModel.startX,
                                                    startY: self.viewModel.startY,
                                                    length: numericValue,
                                                    angle: self.viewModel.angle
                )
            }.store(in: &cancellables)
        
        addVectorView.angleTextField.textPublisher()
            .sink { [weak self] value in
                guard let self,
                      let numericValue = Double(value)
                else { return }
                
                self.viewModel.updateLengthAndAngle(startX: self.viewModel.startX,
                                                    startY: self.viewModel.startY,
                                                    length: self.viewModel.length,
                                                    angle: numericValue
                )
            }.store(in: &cancellables)
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
        
        let newVector = VectorModel(
            id: UUID(),
            startX: startX,
            startY: startY,
            endX: endX,
            endY: endY,
            color: randomColor,
            length: length,
            angle: angle
        )
        
        vectorDidAdd?(newVector)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapClose() {
        navigationController?.popViewController(animated: true)
    }
}
