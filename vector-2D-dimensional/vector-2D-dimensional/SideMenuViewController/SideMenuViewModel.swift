//
//  SideMenuViewModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 14.03.25.
//

import Foundation

class SideMenuViewModel {
    @Published private(set) var vectors: [VectorModel] = []
    
    init() {
        fetchVectors()
    }
    
    private func fetchVectors() {
//        let mockVectors: [VectorModel] = [
//            VectorModel(id: UUID(), startX: 0.0, startY: 0.0, endX: 100.0, endY: 100.0, color: .red),
//        ]
//        
//        vectors = mockVectors
    }
    
    func setData(_ vectors: [VectorModel]) {
        self.vectors = vectors
    }
}
