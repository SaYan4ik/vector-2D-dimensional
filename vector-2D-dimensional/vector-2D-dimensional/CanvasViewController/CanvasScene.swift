//
//  CanvasScene.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import SpriteKit
import UIKit

final class CanvasScene: SKScene {
//    private var vectors: [VectorModel] = []
//    private var vectorsNode: [VectorNode] = []
    private var dragIsStart: Bool = false
    private var selectedNode: SKNode?
    private var initialTouchPoint: CGPoint = .zero
    
    private var rightAngleIndicator: SKShapeNode?
    let cameraNode = SKCameraNode()
    var dragDidEnd: (() -> Void)?
    
    private lazy var vectorManager: VectorManager = {
        VectorManager(scene: self)
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
        let locationInView = gesture.location(in: view)
        let locationInScene = convertPoint(fromView: locationInView)
        
        handleLongPressState(gesture, locationInScene: locationInScene)
    }
    
    private func handleLongPressState(_ gesture: UILongPressGestureRecognizer, locationInScene: CGPoint) {
        switch gesture.state {
            case .began:
                longPressBegin(location: locationInScene)
            case .changed:
                longPressChanged(location: locationInScene)
            case .ended, .cancelled:
                longPressEnded()
                selectedNode = nil
            default:
                break
        }
    }
    
    private func longPressBegin(location: CGPoint) {
        let cutPressDistance = 30.0
        let snapTreshold = 50.0
        var vectorNodes = vectorManager.vectorNodes
        var ts = vectorNodes.map { (location - $0.startPoint).dot($0.v) / $0.v.norm() / $0.v.norm() }
        
        ts = ts.indices.map { ts[$0] < cutPressDistance / vectorNodes[$0].v.norm() ? 0: ts[$0] }
        ts = ts.indices.map { ts[$0] > 1 - cutPressDistance / vectorNodes[$0].v.norm() ? 1: ts[$0] }
        
        let distances = vectorNodes.indices.map { (location - (vectorNodes[$0].startPoint + vectorNodes[$0].v * ts[$0])).norm() }
        let argmin = distances.indices.min { distances[$0] < distances[$1] }!
        
        if distances[argmin] < snapTreshold {
            if ts[argmin] == 0 {
                selectedNode = vectorNodes[argmin].startPointNode
            } else if ts[argmin] == 1 {
                selectedNode = vectorNodes[argmin].endPointNode
            } else {
                selectedNode = vectorNodes[argmin]
                dragIsStart = true
                initialTouchPoint = location
            }
        }
    }
    
    private func longPressChanged(location: CGPoint) {
        guard let selectedNode else {
            print("Node not selected")
            return
        }
        
        var vectorNodes = vectorManager.vectorNodes
        
        if dragIsStart, let vectorNode = selectedNode as? VectorNode {
            let translation = location - initialTouchPoint
            
            vectorNode.move(by: translation)
            initialTouchPoint = location
            updateVectorInRealm(vectorNode)
            
            rightAngleIndicator?.removeFromParent()
            rightAngleIndicator = nil
            
        } else if let pointNode = selectedNode as? SKShapeNode,
                  let vectorNode = pointNode.parent as? VectorNode {
            var newLocation = location
            
            let otherPoint = pointNode == vectorNode.startPointNode ? vectorNode.endPoint : vectorNode.startPoint
            newLocation.x = abs(location.x - otherPoint.x) < 10.0 ? otherPoint.x : location.x
            newLocation.y = abs(location.y - otherPoint.y) < 10.0 ? otherPoint.y : location.y
            
            
            let otherNodes = vectorNodes.filter { $0.id != vectorNode.id }
            if !otherNodes.isEmpty {
                var snapTargets = otherNodes.map { $0.endPoint }
                snapTargets.append(contentsOf: otherNodes.map { $0.startPoint })
                let distancesToSnapTargets = snapTargets.map { ($0 - newLocation).norm() }
                let closestSnapTargetIndex = distancesToSnapTargets.indices.min(by: {distancesToSnapTargets[$0] < distancesToSnapTargets[$1]})!
                
                if Double(distancesToSnapTargets[closestSnapTargetIndex]) < 40.0 {
                    newLocation = snapTargets[closestSnapTargetIndex]
                }
            }
            
            
            if pointNode == vectorNode.startPointNode {
                vectorNode.startPoint = newLocation
            } else if pointNode == vectorNode.endPointNode {
                vectorNode.endPoint = newLocation
            }
            updateVectorInRealm(vectorNode)
            
            let connectedNodes = otherNodes.filter { vectorNode.startPoint == $0.startPoint }
            
            if !connectedNodes.isEmpty {
                let vector = vectorNode.endPoint - vectorNode.startPoint
                let vectorNorm = vector.norm()
                let unitVector = vector / vectorNorm
                
                let connectedVectorsUnits = connectedNodes.map { ($0.endPoint - $0.startPoint).normalized() }
                let scores = connectedVectorsUnits.map { abs(Double($0.dot(unitVector))) }
                let smallestScoreIndex = scores.indices.min(by: {scores[$0] < scores[$1]})!
                if scores[smallestScoreIndex] < 0.05 {
                    
                    let otherVector = connectedVectorsUnits[smallestScoreIndex]
                    let normalVector = CGPoint(x: -otherVector.y, y: otherVector.x)
                    let a = vectorNode.startPoint + normalVector * vectorNorm
                    let b = vectorNode.startPoint - normalVector * vectorNorm
                    vectorNode.endPoint = ((a - newLocation).norm() < (b - newLocation).norm()) ? a : b
                    updateVectorInRealm(vectorNode)
                    
                    drawRightAngleIndicator(at: vectorNode, connectedNodes: connectedNodes)
                } else {
                    rightAngleIndicator?.removeFromParent()
                    rightAngleIndicator = nil
                }
            }
        }
    }
    
    private func drawRightAngleIndicator(at selectedNode: VectorNode, connectedNodes: [VectorNode]) {
        rightAngleIndicator?.removeFromParent()
        rightAngleIndicator = nil
        
        let squareSize: CGFloat = 10.0
        let normNodes = connectedNodes.filter { $0.id != selectedNode.id }.map { $0.v.normalized()}
        let selNode = selectedNode.v.normalized()
        
        for normNode in normNodes {
            let dotProduct = normNode.dot(selNode)
            if abs(dotProduct) < 0.0001 {
                let pos = selectedNode.startPoint + normNode * 5 + selNode * 5
                
                let square = SKShapeNode(rectOf: CGSize(width: squareSize, height: squareSize))
                square.position = pos
                square.zRotation = selectedNode.zRotation()
                square.fillColor = .clear
                square.strokeColor = selectedNode.color
                square.lineWidth = 2.0
                
                if rightAngleIndicator == nil {
                    rightAngleIndicator = SKShapeNode()
                    addChild(rightAngleIndicator!)
                }
                rightAngleIndicator?.addChild(square)
            }
        }
    }
    
    private func updateVectorInRealm(_ vectorNode: VectorNode) {
        vectorManager.updateVectorInRealm(vectorNode)
        dragDidEnd?()
    }
    
    private func longPressEnded() {
        dragIsStart = false
        initialTouchPoint = .zero
    }
}
