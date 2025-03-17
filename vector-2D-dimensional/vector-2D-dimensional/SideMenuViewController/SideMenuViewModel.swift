//
//  SideMenuViewModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 14.03.25.
//

import Foundation

class SideMenuViewModel {
    @Published private(set) var vectors: [VectorModel] = []
    
    init() { }
    
    func setData(_ vectors: [VectorModel]) {
        self.vectors = vectors
    }
}
