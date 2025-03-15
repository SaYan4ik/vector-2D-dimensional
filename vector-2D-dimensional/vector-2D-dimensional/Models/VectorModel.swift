//
//  VectorModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import UIKit

class VectorModel {
    var id: UUID
    var startX: Double
    var startY: Double
    var endX: Double
    var endY: Double
    var color: UIColor
    
    var length: Double {
        return sqrt(pow(endX - startX, 2) + pow(endY - startY, 2))
    }
    
    init(
        id: UUID,
        startX: Double,
        startY: Double,
        endX: Double,
        endY: Double,
        color: UIColor
    ) {
        self.id = id
        self.startX = startX
        self.startY = startY
        self.endX = endX
        self.endY = endY
        self.color = color
    }
}
