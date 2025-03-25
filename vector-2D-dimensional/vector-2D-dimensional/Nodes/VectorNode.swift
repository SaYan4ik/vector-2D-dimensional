//
//  VectorNode.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import SpriteKit


final class VectorNode: SKNode {
    var id: UUID
    var startPointNode: SKShapeNode?
    var endPointNode: SKShapeNode?
    var lineNode: SKShapeNode?
    
    var startPoint: CGPoint {
        didSet {
            updateLine()
        }
    }
    
    var endPoint: CGPoint {
        didSet {
            updateLine()
        }
    }
    
    var v: CGPoint {
        return endPoint - startPoint
    }
    
    var isSelected: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    
    private(set) var color: UIColor
    
    init(id: UUID, startPoint: CGPoint, endPoint: CGPoint, color: UIColor) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.color = color
        
        super.init()
        createVector()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createVector() {
        drawLine()
        createVectorPoints()
    }
    
    private func drawLine() {
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let shapeNode = SKShapeNode(path: path)
        shapeNode.strokeColor = color
        shapeNode.name = "Vector line"
        shapeNode.lineWidth = 3
        lineNode = shapeNode
        addChild(shapeNode)
    }
    
    private func createVectorPoints() {
        startPointNode = createCircle(position: startPoint, radius: 5, color: color)
        endPointNode = createArrowNode(position: endPoint, angle: zRotation())
        
        
        guard let startPointNode,
              let endPointNode
        else { return }
        
        addChild(startPointNode)
        addChild(endPointNode)
    }
    
    private func createCircle(position: CGPoint, radius: CGFloat, color: UIColor)  ->  SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.fillColor = color
        circle.strokeColor = .black
        circle.position = position
        return circle
    }
    
    private func updateLine() {
        let path = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        lineNode?.path = path
        startPointNode?.position = startPoint
        
        endPointNode?.zRotation = zRotation()
        endPointNode?.position = endPoint
    }
    
    func move(by translation: CGPoint) {
        startPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
        endPoint = CGPoint(x: endPoint.x + translation.x, y: endPoint.y + translation.y)
    }
    
    func zRotation() -> CGFloat {
        let v = endPoint - startPoint
        return atan2(v.y, v.x)
    }
    
    private func createArrowNode(position: CGPoint, angle: CGFloat, arrowLength: CGFloat = 15, arrowWidth: CGFloat = 10) -> SKShapeNode {
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -arrowLength, y: arrowWidth / 2))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: -arrowLength, y: -arrowWidth / 2))
        path.closeSubpath()
        
        let arrowNode = SKShapeNode(path: path)
        arrowNode.fillColor = color
        arrowNode.strokeColor = .black
        arrowNode.position = position
        arrowNode.zRotation = angle
        
        return arrowNode
    }
    
    func animationNodeBorder() {
        let duration: TimeInterval = 2.0
        
        let increaseWidth = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let progress = elapsedTime / CGFloat(duration)
            self.lineNode?.lineWidth = 3.0 + 3.0 * progress
            self.startPointNode?.lineWidth = 3.0 + 1.0 * progress
            self.endPointNode?.lineWidth = 3.0 + 1.0 * progress
        }
        
        let decreaseWidth = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let progress = elapsedTime / CGFloat(duration)
            
            self.lineNode?.lineWidth = 6.0 - 3.0 * progress
            self.startPointNode?.lineWidth = 4.0 - 3.0 * progress
            self.endPointNode?.lineWidth = 4.0 - 3.0 * progress
        }
        
        let sequence = SKAction.sequence([increaseWidth, decreaseWidth])
        
        lineNode?.run(sequence)
        startPointNode?.run(sequence)
        endPointNode?.run(sequence)
    }
    
    private func updateSelectionState() {
        if isSelected {
            let highlightColor = color.withAlphaComponent(0.8)
            lineNode?.strokeColor = highlightColor
            startPointNode?.fillColor = highlightColor
            endPointNode?.fillColor = highlightColor
            
            let scaleAction = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.2),
                SKAction.scale(to: 1.0, duration: 0.2)
            ])
            
            let repeatForever = SKAction.repeatForever(scaleAction)
            
            startPointNode?.run(repeatForever)
            endPointNode?.run(repeatForever)
        } else {
            lineNode?.strokeColor = color
            startPointNode?.fillColor = color
            endPointNode?.fillColor = color
            
            startPointNode?.setScale(1.0)
            endPointNode?.setScale(1.0)
            
            lineNode?.removeAllActions()
            startPointNode?.removeAllActions()
            endPointNode?.removeAllActions()
        }
    }
}
