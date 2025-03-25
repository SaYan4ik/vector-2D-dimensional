//
//  SideMenuViewModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 14.03.25.
//

import Foundation

final class SideMenuViewModel {
    @Published private(set) var vectors: [VectorModel] = []
    
    init() {
        fetchVectors()
    }
    
    func fetchVectors() {
        self.vectors = RealmManager.shared.read(ofType: VectorModel.self)
    }
}
