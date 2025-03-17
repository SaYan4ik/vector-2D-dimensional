//
//  CanvasScene.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import SpriteKit
import UIKit

class CanvasScene: SKScene {
    private var vectors: [VectorModel] = []
    private var dragIsStart: Bool = false
    private var selectedNode: SKNode?
    private var initialTouchPoint: CGPoint = .zero
    
    private let cameraNode = SKCameraNode()
    private var lastTouchPosition: CGPoint?
    var dragDidEnd: (() -> Void)?
        
    override init(size: CGSize = .zero) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.camera = cameraNode
        addChild(cameraNode)
        
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
        self.vectors = vectors
        removeAllChildren()
        
        for vector in vectors {            
            drawVectorNode(vector)
        }
    }
    
    private func drawVectorNode(_ vector: VectorModel) {
        let vectorNode = VectorNode(
            id: vector.id,
            startPoint: CGPoint(x: vector.startX, y: vector.startY),
            endPoint: CGPoint(x: vector.endX, y: vector.endY),
            color: vector.color
        )
        
        addChild(vectorNode)
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
        
        switch gesture.state {
            case .began:
                longPressBegin(location: locationInScene)
            case .changed:
                longPressChanged(location: locationInScene)
            case .ended, .cancelled:
                longPressEnded()
                dragDidEnd?()
            default:
                break
        }
    }
    
    private func longPressBegin(location: CGPoint) {
        selectedNode = nodes(at: location).first
        
        guard let shapeNode = selectedNode as? SKShapeNode,
              let vectorNode = shapeNode.parent as? VectorNode else {
            
            print("Node not selected or not part of a VectorNode")
            longPressEnded()
            return
        }
        
        if shapeNode.name == "Vector line" {
            self.selectedNode = vectorNode
            dragIsStart = true
            initialTouchPoint = location
        } else if shapeNode == vectorNode.startPointNode || shapeNode == vectorNode.endPointNode {
            self.selectedNode = shapeNode
            longPressEnded()
        } else {
            longPressEnded()
        }
    }
    
    private func longPressChanged(location: CGPoint) {
        guard let selectedNode = selectedNode else {
            print("Node not selected")
            return
        }
        
        if dragIsStart, let vectorNode = selectedNode as? VectorNode {
            let translation = CGPoint(
                x: location.x - initialTouchPoint.x,
                y: location.y - initialTouchPoint.y
            )
            
            vectorNode.move(by: translation)
            initialTouchPoint = location
            updateVectorInRealm(vectorNode)
            
        } else if let pointNode = selectedNode as? SKShapeNode,
                  let vectorNode = pointNode.parent as? VectorNode {
            pointNode.position = location
            
            if pointNode == vectorNode.startPointNode {
                vectorNode.startPoint = location
            } else if pointNode == vectorNode.endPointNode {
                vectorNode.endPoint = location
            }
            
            updateVectorInRealm(vectorNode)
        }
    }
    
    private func updateVectorInRealm(_ vectorNode: VectorNode) {
        guard let vectorModel = vectors.first(where: { $0.id == vectorNode.id }) else {
            return
        }
        
        let dx = Double(vectorNode.endPoint.x) - Double(vectorNode.startPoint.x)
        let dy = Double(vectorNode.endPoint.y) - Double(vectorNode.startPoint.y)
        
        RealmManager.shared.update { realm in
            vectorModel.startX = Double(vectorNode.startPoint.x)
            vectorModel.startY = Double(vectorNode.startPoint.y)
            vectorModel.endX = Double(vectorNode.endPoint.x)
            vectorModel.endY = Double(vectorNode.endPoint.y)
            vectorModel.length = sqrt(dx * dx + dy * dy)
            vectorModel.angle = atan2(dy, dx)
            realm.add(vectorModel, update: .modified)
        }
    }
    
    private func longPressEnded() {
        dragIsStart = false
        initialTouchPoint = .zero
    }
    
}
