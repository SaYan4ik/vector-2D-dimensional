//
//  CanvasViewModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import UIKit
import Combine


final class CanvasViewModel {
    @Published private(set) var vectors: [VectorModel] = []
    
    init() {
        fetchVectors()
    }
    
    func fetchVectors() {        
        self.vectors = RealmManager.shared.read(ofType: VectorModel.self)
    }
    
    func addVector(
        startX: Double,
        startY: Double,
        endX: Double,
        endY: Double,
        color: UIColor,
        length: Double,
        angle: Double
    ) {
        let newVector = VectorModel(
            id: UUID(),
            startX: startX,
            startY: startY,
            endX: endX,
            endY: endY,
            color: color,
            length: length,
            angle: angle
        )
        
        vectors.append(newVector)
        RealmManager.shared.write(newVector)
    }
    
    func removeVector(by id: UUID) {
        if let id = vectors.firstIndex(where: { $0.id == id }) {
            RealmManager.shared.delete(object: vectors[id])
        }
        
        vectors = RealmManager.shared.read(ofType: VectorModel.self)
    }
}
