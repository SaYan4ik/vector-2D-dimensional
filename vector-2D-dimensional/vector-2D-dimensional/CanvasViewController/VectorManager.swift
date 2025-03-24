//
//  VectorRenderer.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 24.03.25.
//

import Foundation
import SpriteKit

protocol VectorManagable {
    func updateVectors(_ vectors: [VectorModel])
    func getVectorNodes() -> [VectorNode]
    func updateVectorInRealm(_ vectorNode: VectorNode)
}

class VectorManager: VectorManagable {
    private(set) var vectors: [VectorModel] = []
    private(set) var vectorNodes: [VectorNode] = []
    private weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func updateVectors(_ vectors: [VectorModel]) {
        self.vectors = vectors
        clearScene()
        drawAllVectors()
    }
    
    func getVectorNodes() -> [VectorNode] {
        vectorNodes
    }
    
    func getVectorNode(by id: UUID) -> VectorNode? {
        return vectorNodes.first { $0.id == id }
    }
    
    private func clearScene() {
        vectorNodes.forEach { $0.removeFromParent() }
        vectorNodes.removeAll()
    }
    
    private func drawAllVectors() {
        for vector in vectors {
            drawVector(vector)
        }
    }
    
    private func drawVector(_ vector: VectorModel) {
        let vectorNode = VectorNode(
            id: vector.id,
            startPoint: CGPoint(x: vector.startX, y: vector.startY),
            endPoint: CGPoint(x: vector.endX, y: vector.endY),
            color: vector.color
        )
        
        vectorNodes.append(vectorNode)
        scene?.addChild(vectorNode)
    }

    func updateVectorInRealm(_ vectorNode: VectorNode) {
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
}
