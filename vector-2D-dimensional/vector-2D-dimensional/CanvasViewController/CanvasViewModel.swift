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
    
    private func fetchVectors() {
        let mockVectors: [VectorModel] = [
            VectorModel(id: UUID(), startX: 0.0, startY: 0.0, endX: 100.0, endY: 100.0, color: .red),
//            VectorModel(id: UUID(), startX: 50.0, startY: 50.0, endX: 150.0, endY: 150.0, color: .green),
//            VectorModel(id: UUID(), startX: 100.0, startY: 100.0, endX: 200.0, endY: 200.0, color: .blue),
            VectorModel(id: UUID(), startX: 200.0, startY: 200.0, endX: 300.0, endY: 300.0, color: .yellow)
        ]
        
        vectors = mockVectors
    }
    
    func addVector(
        startX: Double,
        startY: Double,
        endX: Double,
        endY: Double,
        color: UIColor
    ) {
        let newVector = VectorModel(
            id: UUID(),
            startX: startX,
            startY: startY,
            endX: endX,
            endY: endY,
            color: color
        )
        vectors.append(newVector)
    }
}
