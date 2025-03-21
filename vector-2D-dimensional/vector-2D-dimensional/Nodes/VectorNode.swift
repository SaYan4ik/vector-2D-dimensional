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
    var rightAngleIndicator: SKShapeNode?
    
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
    private var snapTreshold: CGFloat = 10.0

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
        shapeNode.lineWidth = 1
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
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        return atan2(dy, dx)
    }
    
    private func calculateVector(_ start: CGPoint, _ end: CGPoint) -> CGPoint {
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        return CGPoint(x: dx, y: dy)
    }
    
    private func lengthOfVector(_ vector: CGPoint) -> CGFloat {
        
        return sqrt(vector.x * vector.x + vector.y * vector.y)
    }
    
    private func angleBetweenVectors(_ vector1: CGPoint, _ vector2: CGPoint) -> CGFloat {
        let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y
        let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
        let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)
        let cosAlfa = dotProduct/(magnitude1 * magnitude2)
        
        return acos(cosAlfa)
    }
    
    private func angelInDegree(acos: CGFloat) -> CGFloat {
        let degree = acos * 180 / .pi
        
        return degree
    }
    
    private func checkIfAngle90Degree(with treshold: CGFloat = 1, for angle: CGFloat) -> Bool {
        let lowerBound: CGFloat = 90 - treshold
        let upperBound: CGFloat = 90 + treshold
        
        return (lowerBound...upperBound).contains(angle)
    }
    
    func perpendicularVector(from vector: CGPoint) -> CGPoint {
        
        return CGPoint(x: -vector.y, y: vector.x)
    }
    
    private func normalize(vector: CGPoint)  -> CGPoint {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y)
        
        return CGPoint(x: vector.x / length, y: vector.y / length)
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
    
    func animationNodeBorder() {
        let duration: TimeInterval = 2.0
        
        let increaseWidth = SKAction.customAction(withDuration: duration) { node, elapsedTime in
                let progress = elapsedTime / CGFloat(duration)
                self.lineNode?.lineWidth = 1.0 + 3.0 * progress
                self.startPointNode?.lineWidth = 1.0 + 3.0 * progress
                self.endPointNode?.lineWidth = 1.0 + 3.0 * progress
        }
        
        let decreaseWidth = SKAction.customAction(withDuration: duration) { node, elapsedTime in
                let progress = elapsedTime / CGFloat(duration)
                
                self.lineNode?.lineWidth = 4.0 - 3.0 * progress
                self.startPointNode?.lineWidth = 4.0 - 3.0 * progress
                self.endPointNode?.lineWidth = 4.0 - 3.0 * progress
        }
        
        let sequence = SKAction.sequence([increaseWidth, decreaseWidth])
        
        lineNode?.run(sequence)
        startPointNode?.run(sequence)
        endPointNode?.run(sequence)
    }

    
    func updateNodePos(point: inout CGPoint, isStartPoint: Bool, vectors: [VectorNode]) {
        let refPoint = isStartPoint ? endPoint : startPoint
        point = snapNodeByVerticalOrHorizontal(point: point, startPoint: refPoint)
        point = snapToOtherVectors(point: point, vectors: vectors)
//        point = checkIfAngle90Degree(point: point, vector: vectors, isStartPoint: isStartPoint)
        
        if isStartPoint {
            startPoint = point
        } else {
            endPoint = point
        }
    }
    
    private func snapNodeByVerticalOrHorizontal(point: CGPoint, startPoint: CGPoint) -> CGPoint {
        var snappedPoint = point
        
        if abs(point.y - startPoint.y) < snapTreshold {
            snappedPoint.y = startPoint.y
        }
        
        if abs(point.x - startPoint.x) < snapTreshold {
            snappedPoint.x = startPoint.x
        }
        
        return snappedPoint
    }
    
    private func snapToOtherVectors(point: CGPoint, vectors: [VectorNode]) -> CGPoint {
        var snappedPoint = point
        
        for vector in vectors {
            if vector.id != self.id {
                if abs(point.x - vector.startPoint.x) < snapTreshold && abs(point.y - vector.startPoint.y) < snapTreshold {
                    snappedPoint = vector.startPoint
                    break
                }
                
                if abs(point.x - vector.endPoint.x) < snapTreshold && abs(point.y - vector.endPoint.y) < snapTreshold {
                    snappedPoint = vector.endPoint
                    break
                }
            }
        }
        
        return snappedPoint
    }
    
    private func checkIfAngle90Degree(point: CGPoint, vector: [VectorNode], isStartPoint: Bool) -> CGPoint {
        var snappedPoint = point
        
        let calculateSelfVector = calculateVector(self.startPoint, endPoint)
                
        for vector in vector {
            if vector.id != self.id {
                let calculateOtherVector = calculateVector(vector.startPoint, vector.endPoint)
                let angle = angleBetweenVectors(calculateSelfVector, calculateOtherVector)
                let angleInDegree = angelInDegree(acos: angle)
                
                
                if checkIfAngle90Degree(for: angleInDegree) {
                    print("Угол \(angleInDegree) близок к 90 градусам")
                    let perpendVect = perpendicularVector(from: calculateOtherVector)
                    let normalize = normalize(vector: perpendVect)
                    
                    let length = sqrt(calculateSelfVector.x * calculateSelfVector.x + calculateSelfVector.y * calculateSelfVector.y)
                    let perpendSelfVector = CGPoint(x: normalize.x * length, y: normalize.y * length)
                    
                    if isStartPoint {
                        snappedPoint = CGPoint(x: startPoint.x + perpendSelfVector.x, y: startPoint.y + perpendSelfVector.y)
                        break
                    } else {
                        snappedPoint = CGPoint(x: endPoint.x - perpendSelfVector.x, y: endPoint.y - perpendSelfVector.y)
                        break
                    }
                }
            }
        }
        
        return snappedPoint
    }
    
}
