//
//  CanvasViewController.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import UIKit
import Combine
import SpriteKit


class CanvasViewController: UIViewController, SideMenuViewControllerDelegate {
    
    private var scene: CanvasScene = {
        let scene = CanvasScene()
        scene.backgroundColor = .lightGray
        return scene
    }()
    
    private lazy var hamburgerMenuButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.addTarget(self, action: #selector(hamburgerMenuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var sideMenuViewController: SideMenuViewController!
    private var sideMenuWidth: CGFloat = 0
    private var isSideMenuShown: Bool = false
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    
    private var viewModel: CanvasViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CanvasViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupNavBar()
        
        sideMenuWidth = view.bounds.width * 0.33
        configureSideMenu()
        
        bindViewModel()
        
        scene.addGesture()
    }
    
    private func bindViewModel() {
        viewModel.$vectors.sink { [weak self] vectors in
            print(vectors)
            self?.sideMenuViewController.setViewModelData(vectors)
            self?.scene.updateVectors(vectors)
        }.store(in: &cancellables)
        
        scene.dragDidEnd = {
            self.viewModel.fetchVectors()
        }
    }
    
    private func setupScene() {
        let skView = SKView(frame: view.bounds)
        skView.backgroundColor = .clear
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
        view.addSubview(skView)
    }
    
    private func setupNavBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addVector))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerMenuButton)
    }
    
    @objc func addVector() {
        let addVectorVC = AddVectorViewController(viewModel: viewModel)
        navigationController?.pushViewController(addVectorVC, animated: true)
    }
}

extension CanvasViewController {
    private func configureSideMenu() {
        let viewModel = SideMenuViewModel()
        viewModel.setData(viewModel.vectors)
        
        sideMenuViewController = SideMenuViewController(viewModel: viewModel)
        sideMenuViewController.delegate = self
        view.addSubview(self.sideMenuViewController.view)
        addChild(self.sideMenuViewController)
        
        sideMenuWidth = view.bounds.width * 0.33
        
        sideMenuViewController.didMove(toParent: self)
        sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -self.sideMenuWidth)
        sideMenuTrailingConstraint.isActive = true
        
        setupSideMenuConstrain()
        
        
        let edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipe))
        edgePanGestureRecognizer.edges = .left
        self.view.addGestureRecognizer(edgePanGestureRecognizer)
    }
    
    private func setupSideMenuConstrain() {
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
    }
    
    @objc private func hamburgerMenuButtonTapped(_ sender: UIButton) {
        self.sideMenuState(expanded: self.isSideMenuShown ? false : true)
    }
    
    private func sideMenuState(expanded: Bool) {
        let targetPosition = expanded ? 0 : -self.sideMenuWidth
        self.animateSideMenu(targetPosition: targetPosition) { _ in
            self.isSideMenuShown = expanded
        }
    }
    
    private func expand(isExpand: Bool ) {
        sideMenuState(expanded: isExpand)
    }
    
    private func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: .layoutSubviews,
                       animations: {
            
            self.sideMenuTrailingConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
            
        }, completion: completion)
    }
    
}

extension CanvasViewController: UIGestureRecognizerDelegate {
    
    @objc private func shadowViewTapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isSideMenuShown {
                self.sideMenuState(expanded: false)
            }
        }
    }
    
    @objc private func handleEdgeSwipe(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            self.sideMenuState(expanded: self.isSideMenuShown ? false : true)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.sideMenuViewController.view))! {
            return false
        }
        return true
    }
}

extension CanvasViewController {
    func didSelectCell(_ row: Int, id: UUID) {
        DispatchQueue.main.async {
//            self.sideMenuState(expanded: false)
        }
    }
}
