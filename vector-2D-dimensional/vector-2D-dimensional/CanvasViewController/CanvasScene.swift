//
//  CanvasScene.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import SpriteKit
import UIKit

final class CanvasScene: SKScene {
    var dragDidEnd: (() -> Void)?
    let cameraNode = SKCameraNode()
    
    private lazy var vectorManager: VectorManagable = {
        VectorManager(scene: self)
    }()

    private lazy var movementHandler = VectorMovementManager(vectorManager: vectorManager, scene: self)

    
    override init(size: CGSize = .zero) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        DispatchQueue.main.async {
            self.setupCamera(for: view)
        }
        
        movementHandler.dragDidEnd = { [weak self] in
            self?.dragDidEnd?()
        }
    }
    
    private func drawGridCells() {
        let height = 4000.0
        let width = 4000.0
        
        let cellSize: CGFloat = 30.0
        let rows = Int( height / cellSize)
        let cols = Int( width / cellSize)
        
        for col in 0...cols {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: CGFloat(col) * cellSize, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(col) * cellSize, y: height))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = .gray
            line.lineWidth = 1.0
            self.addChild(line)
        }
        
        for row in 0...rows {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: CGFloat(row) * cellSize))
            path.addLine(to: CGPoint(x: width, y: CGFloat(row) * cellSize))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = .gray
            line.lineWidth = 1.0
            self.addChild(line)
        }
    }
    
    private func setupCamera(for view: SKView) {
        self.camera = self.cameraNode
        self.addChild(self.cameraNode)
        
        self.handlePanCanvas(on: view)
    }
    
    private func handlePanCanvas(on view: SKView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        
        if gesture.state == .changed {
            let newPosition = CGPoint(
                x: cameraNode.position.x - translation.x,
                y: cameraNode.position.y + translation.y
            )
            
            cameraNode.position = newPosition
            gesture.setTranslation(.zero, in: gesture.view)
        }
    }
    
    func updateVectors(_ vectors: [VectorModel]) {
        vectorManager.updateVectors(vectors)
    }

    func addGesture(){
        guard let view else { return }
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.3
        view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard let view = view else { return }
        movementHandler.handleLongPress(gesture: gesture, in: view)
    }
}
