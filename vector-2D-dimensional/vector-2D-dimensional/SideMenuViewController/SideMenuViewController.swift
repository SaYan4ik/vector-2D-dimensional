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
}

class SideMenuViewController: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SideMenuTableViewCell.self, forCellReuseIdentifier: String(describing: SideMenuTableViewCell.self))
        tableView.backgroundColor = .cyan
        tableView.estimatedRowHeight = 65
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    private var cancellables = Set<AnyCancellable>()
    weak var delegate: SideMenuViewControllerDelegate?
    var dataSource: [VectorModel] = []
    
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
            print("Side menu", vectors)
            
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
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setViewModelData(_ vectors: [VectorModel]) {
        viewModel.setData(vectors)
    }
}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SideMenuTableViewCell.self), for: indexPath)
        guard let vectorCell = cell as? SideMenuTableViewCell else { return cell}
        vectorCell.set(vector: dataSource[indexPath.row])
        
        return vectorCell
    }
    
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.didSelectCell(indexPath.row, id: dataSource[indexPath.row].id)
    }
}
