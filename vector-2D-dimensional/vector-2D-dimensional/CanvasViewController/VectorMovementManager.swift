//
//  VectorMovementManager.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 24.03.25.
//

import SpriteKit


protocol VectorMovementable {
    func handleLongPress(gesture: UILongPressGestureRecognizer, in view: SKView)
    var dragDidEnd: (() -> Void)? { get set }
}

final class VectorMovementManager: VectorMovementable {
    private var vectorManager: VectorManagable?
    private weak var scene: SKScene?
    
    private var dragIsStart: Bool = false
    private var selectedNode: SKNode?
    private var initialTouchPoint: CGPoint = .zero
    private var rightAngleIndicator: SKShapeNode?
    
    var dragDidEnd: (() -> Void)?
    
    init(vectorManager: VectorManagable, scene: SKScene) {
        self.vectorManager = vectorManager
        self.scene = scene
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer, in view: SKView) {
        let locationInView = gesture.location(in: view)
        let locationInScene = scene?.convertPoint(fromView: locationInView) ?? .zero
        
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
        guard let vectorNodes = vectorManager?.getVectorNodes() else { return }
        
        let cutPressDistance = 30.0
        let snapTreshold = 50.0
        
        var ts = vectorNodes.map { (location - $0.startPoint).dot($0.v) / $0.v.norm() / $0.v.norm() }
        
        ts = ts.indices.map { ts[$0] < cutPressDistance / vectorNodes[$0].v.norm() ? 0 : ts[$0] }
        ts = ts.indices.map { ts[$0] > 1 - cutPressDistance / vectorNodes[$0].v.norm() ? 1 : ts[$0] }
        
        let distances = vectorNodes.indices.map {
            (location - (vectorNodes[$0].startPoint + vectorNodes[$0].v * ts[$0])).norm()
        }
        
        guard let argmin = distances.indices.min(by: { distances[$0] < distances[$1] }),
              distances[argmin] < snapTreshold else { return }
        
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
    
    private func longPressChanged(location: CGPoint) {
        guard let selectedNode else { return }
        
        if dragIsStart, let vectorNode = selectedNode as? VectorNode {
            let translation = location - initialTouchPoint
            vectorNode.move(by: translation)
            initialTouchPoint = location
            updateVectorInRealm(vectorNode)
            clearRightAngleIndicator()
            vectorNode.isSelected = true

            
        } else if let pointNode = selectedNode as? SKShapeNode,
                  let vectorNode = pointNode.parent as? VectorNode {
            var newLocation = location
            vectorNode.isSelected = true
            
            let otherPoint = pointNode == vectorNode.startPointNode ? vectorNode.endPoint : vectorNode.startPoint
            newLocation.x = abs(location.x - otherPoint.x) < 10.0 ? otherPoint.x : location.x
            newLocation.y = abs(location.y - otherPoint.y) < 10.0 ? otherPoint.y : location.y
            
            let otherNodes = vectorManager?.getVectorNodes().filter { $0.id != vectorNode.id } ?? []
            if !otherNodes.isEmpty {
                var snapTargets = otherNodes.map { $0.endPoint }
                snapTargets.append(contentsOf: otherNodes.map { $0.startPoint })
                let distances = snapTargets.map { ($0 - newLocation).norm() }
                if let closestIndex = distances.indices.min(by: { distances[$0] < distances[$1] }),
                   distances[closestIndex] < 40.0 {
                    newLocation = snapTargets[closestIndex]
                }
            }
            
            if pointNode == vectorNode.startPointNode {
                vectorNode.startPoint = newLocation
            } else if pointNode == vectorNode.endPointNode {
                vectorNode.endPoint = newLocation
            }
            
            updateVectorInRealm(vectorNode)
            checkForRightAngle(vectorNode)
        }
    }
    
    private func longPressEnded() {
        dragIsStart = false
        initialTouchPoint = .zero
        (selectedNode as? VectorNode)?.isSelected = false
        (selectedNode?.parent as? VectorNode)?.isSelected = false
        dragDidEnd?()
    }
    
    private func checkForRightAngle(_ vectorNode: VectorNode) {
        guard let allVectors = vectorManager?.getVectorNodes() else { return }
        let otherNodes = allVectors.filter { $0.id != vectorNode.id }
        let connectedNodes = otherNodes.filter { vectorNode.startPoint == $0.startPoint }
        
        guard !connectedNodes.isEmpty else {
            clearRightAngleIndicator()
            return
        }
        
        let vector = vectorNode.endPoint - vectorNode.startPoint
        let vectorNorm = vector.norm()
        let unitVector = vector / vectorNorm
        
        let connectedVectorsUnits = connectedNodes.map { ($0.endPoint - $0.startPoint).normalized() }
        let scores = connectedVectorsUnits.map { abs(Double($0.dot(unitVector))) }
        
        if let smallestScoreIndex = scores.indices.min(by: { scores[$0] < scores[$1] }),
           scores[smallestScoreIndex] < 0.05 {
            
            let otherVector = connectedVectorsUnits[smallestScoreIndex]
            let normalVector = CGPoint(x: -otherVector.y, y: otherVector.x)
            let a = vectorNode.startPoint + normalVector * vectorNorm
            let b = vectorNode.startPoint - normalVector * vectorNorm
            vectorNode.endPoint = ((a - vectorNode.endPoint).norm() < (b - vectorNode.endPoint).norm()) ? a : b
            
            updateVectorInRealm(vectorNode)
            drawRightAngleIndicator(at: vectorNode, connectedNodes: connectedNodes)
        } else {
            clearRightAngleIndicator()
        }
    }
    
    private func drawRightAngleIndicator(at selectedNode: VectorNode, connectedNodes: [VectorNode]) {
        clearRightAngleIndicator()
        
        let squareSize: CGFloat = 10.0
        let normNodes = connectedNodes.filter { $0.id != selectedNode.id }.map { $0.v.normalized() }
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
                    scene?.addChild(rightAngleIndicator!)
                }
                rightAngleIndicator?.addChild(square)
            }
        }
    }
    
    private func clearRightAngleIndicator() {
        rightAngleIndicator?.removeFromParent()
        rightAngleIndicator = nil
    }
    
    private func updateVectorInRealm(_ vectorNode: VectorNode) {
        vectorManager?.updateVectorInRealm(vectorNode)
    }
}
