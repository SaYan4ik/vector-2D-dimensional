//
//  SideMenuViewController.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 14.03.25.
//

import UIKit
import Combine


protocol SideMenuViewControllerDelegate: AnyObject {
    func didSelectCell(_ row: Int, id: UUID)
    func didDeleteCell(_ row: Int, id: UUID)
}

final class SideMenuViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SideMenuTableViewCell.self, forCellReuseIdentifier: String(describing: SideMenuTableViewCell.self))
        tableView.backgroundColor = Themes.primaryBackground
        tableView.estimatedRowHeight = 65
        tableView.rowHeight = UITableView.automaticDimension
        
        return tableView
    }()
    
    private lazy var noVectorsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Themes.primaryBackgroundSecondary.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var noVectorLabel: UILabel = {
        let label = UILabel()
        label.textColor = Themes.textPrimary
        label.text = "No vectors"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: SideMenuViewControllerDelegate?
    private var dataSource: [VectorModel] = []
    private let gradientLayer = CAGradientLayer()
    
    private var viewModel: SideMenuViewModel
    
    init(viewModel: SideMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        setupTableView()
    }
    
    private func bindViewModel() {
        viewModel.$vectors.sink { [weak self] vectors in            
            self?.dataSource = vectors
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(noVectorsView)
        noVectorsView.addSubview(noVectorLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            noVectorsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noVectorsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noVectorLabel.topAnchor.constraint(equalTo: noVectorsView.topAnchor, constant: 16),
            noVectorLabel.leadingAnchor.constraint(equalTo: noVectorsView.leadingAnchor, constant: 16),
            noVectorLabel.trailingAnchor.constraint(equalTo: noVectorsView.trailingAnchor, constant: -16),
            noVectorLabel.bottomAnchor.constraint(equalTo: noVectorsView.bottomAnchor, constant: -16)
        ])
    }
    
    func updateVectors() {
        viewModel.fetchVectors()
        print("update vectros side menue")
    }
}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty {
            noVectorsView.isHidden = false
            return 0
        } else {
            noVectorsView.isHidden = true
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SideMenuTableViewCell.self), for: indexPath)
        guard let vectorCell = cell as? SideMenuTableViewCell else { return cell}
        vectorCell.set(vector: dataSource[indexPath.row])
        
        return vectorCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let vector = dataSource[indexPath.row]
            self.delegate?.didDeleteCell(indexPath.row, id: vector.id)
            
            updateVectors()
            tableView.reloadData()
        }
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vector = dataSource[indexPath.row]
        self.delegate?.didSelectCell(indexPath.row, id: vector.id)
    }
}
