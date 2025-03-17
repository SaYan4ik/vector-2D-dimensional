//
//  CanvasViewModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import UIKit
import Combine


class CanvasViewModel {
    @Published private(set) var vectors: [VectorModel] = []
    
    init() {
        fetchVectors()
    }
    
    func fetchVectors() {        
        let vectors = RealmManager.shared.read(ofType: VectorModel.self)
        self.vectors = vectors
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
}
