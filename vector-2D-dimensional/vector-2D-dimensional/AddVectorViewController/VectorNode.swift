//
//  VectorNode.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import SpriteKit


class VectorNode: SKNode {
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
    
    private var color: UIColor
    
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
        shapeNode.lineWidth = 2
        lineNode = shapeNode
        addChild(shapeNode)
    }
    
    private func createVectorPoints() {
        startPointNode = createCircle(position: startPoint, radius: 5, color: color)
        endPointNode = createArrowNode(position: endPoint, angle: angleBetweenPoints(startPoint, endPoint))
        
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
        
        endPointNode?.zRotation = angleBetweenPoints(startPoint, endPoint)
        endPointNode?.position = endPoint
    }
    
    func move(by translation: CGPoint) {
        startPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
        endPoint = CGPoint(x: endPoint.x + translation.x, y: endPoint.y + translation.y)
    }
    
    private func angleBetweenPoints(_ start: CGPoint, _ end: CGPoint) -> CGFloat {
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        return atan2(deltaY, deltaX)
    }
    
    private func createArrowNode(position: CGPoint, angle: CGFloat) -> SKShapeNode {
        let arrowLength: CGFloat = 15
        let arrowWidth: CGFloat = 10
        
        let path = CGMutablePath()

        path.move(to: CGPoint(x: 0, y: arrowWidth / 2))
        path.addLine(to: CGPoint(x: arrowLength, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -arrowWidth / 2))
        path.closeSubpath()
        
        let arrowNode = SKShapeNode(path: path)
        arrowNode.fillColor = color
        arrowNode.strokeColor = .black
        arrowNode.position = position
        arrowNode.zRotation = angle
                
        return arrowNode
    }
}
