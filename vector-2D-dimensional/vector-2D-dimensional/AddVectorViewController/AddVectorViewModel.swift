//
//  AddVectorViewModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 17.03.25.
//
import Foundation
import Combine


class AddVectorViewModel {
    @Published var startX: Double = 0
    @Published var startY: Double = 0
    @Published var endX: Double = 0
    @Published var endY: Double = 100
    @Published var length: Double = 100
    @Published var angle: Double = 90

    func updateCoordinates(startX: Double, startY: Double, endX: Double, endY: Double) {
        guard !startX.isNaN, !startY.isNaN, !endX.isNaN, !endY.isNaN else {
            print("Invalid input: NaN detected in coordinates")
            return
        }
        
        self.startX = startX
        self.startY = startY
        self.endX = endX
        self.endY = endY

        let dx = endX - startX
        let dy = endY - startY
        length = sqrt(dx * dx + dy * dy)
        angle = atan2(dy, dx) * 180 / .pi
    }

    func updateLengthAndAngle(startX: Double, startY: Double, length: Double, angle: Double) {
        guard !startX.isNaN, !startY.isNaN, !length.isNaN, !angle.isNaN else {
            print("Invalid input: NaN detected in coordinates")
            return
        }
        
        self.startX = startX
        self.startY = startY
        self.length = length
        self.angle = angle

        let radians = angle * .pi / 180

        endX = startX + length * cos(radians)
        endY = startY + length * sin(radians)
    }
}
