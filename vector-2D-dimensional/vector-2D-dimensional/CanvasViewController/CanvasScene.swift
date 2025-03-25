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

    private lazy var movementHandler: VectorMovementable = {
        VectorMovementManager(vectorManager: vectorManager, scene: self)
    }()
    
    override init(size: CGSize = .zero) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        DispatchQueue.main.async {
            self.setupCamera(for: view)
            self.drawGridCells()
        }
        
        movementHandler.dragDidEnd = { [weak self] in
            self?.dragDidEnd?()
        }
    }
    
    private func drawGridCells() {
        let cellSize: CGFloat = 30.0
        let gridExtent: CGFloat = 2000.0
        let gridColor = SKColor(white: 0.8, alpha: 1.0)
        let axisColor = SKColor(white: 0.5, alpha: 1.0)
        
        let verticalLines = Int(gridExtent / cellSize)
        let horizontalLines = Int(gridExtent / cellSize)
        
        for i in -verticalLines...verticalLines {
            let x = CGFloat(i) * cellSize
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: -gridExtent))
            path.addLine(to: CGPoint(x: x, y: gridExtent))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = .gray
            line.lineWidth = 1.0
            self.addChild(line)
        }
        
        for i in -horizontalLines...horizontalLines {
            let y = CGFloat(i) * cellSize
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -gridExtent, y: y))
            path.addLine(to: CGPoint(x: gridExtent, y: y))
            
            let line = SKShapeNode(path: path)
            line.strokeColor = gridColor
            line.lineWidth = 1.0
            self.addChild(line)
        }
        
        let axisPath = CGMutablePath()
        axisPath.move(to: CGPoint(x: -gridExtent, y: 0))
        axisPath.addLine(to: CGPoint(x: gridExtent, y: 0))
        axisPath.move(to: CGPoint(x: 0, y: -gridExtent))
        axisPath.addLine(to: CGPoint(x: 0, y: gridExtent))
        
        let axis = SKShapeNode(path: axisPath)
        axis.strokeColor = axisColor
        axis.lineWidth = 2.0
        self.addChild(axis)
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
    
    func centerCamera(on node: SKNode, duration: TimeInterval = 0.5) {        
        let cameraPosition = node.position
        moveCamera(to: cameraPosition, duration: duration)
    }
    
    private func moveCamera(to position: CGPoint, duration: TimeInterval = 0.5) {
        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        cameraNode.run(moveAction)
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
        guard let view else { return }
        movementHandler.handleLongPress(gesture: gesture, in: view)
    }
}
