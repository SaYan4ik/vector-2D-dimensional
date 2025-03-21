//
//  VectorModel.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 13.03.25.
//

import UIKit
import RealmSwift

class VectorModel: Object {
    @objc dynamic var id: UUID = UUID()
    @objc dynamic var startX: Double = 0.0
    @objc dynamic var startY: Double = 0.0
    @objc dynamic var endX: Double = 0.0
    @objc dynamic var endY: Double = 0.0
    @objc dynamic var colorData: Data?
    @objc dynamic var length: Double = 0.0
    @objc dynamic var angle: Double = 0.0
    
    var color: UIColor {
        get {
            guard let data = colorData else { return UIColor.clear }
            return UIColor(data: data) ?? UIColor.clear
        }
        set {
            colorData = newValue.toData()
        }
    }
    
    convenience init(
        id: UUID,
        startX: Double,
        startY: Double,
        endX: Double,
        endY: Double,
        color: UIColor,
        length: Double,
        angle: Double
    ) {
        self.init()
        self.id = id
        self.startX = startX
        self.startY = startY
        self.endX = endX
        self.endY = endY
        self.color = color
        self.length = length
        self.angle = angle
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension UIColor {
    func toData() -> Data? {
        guard let components = cgColor.components else { return nil }
        var rgba = [UInt8]()
        rgba.append(UInt8(components[0] * 255.0))
        rgba.append(UInt8(components[1] * 255.0))
        rgba.append(UInt8(components[2] * 255.0))
        rgba.append(UInt8(components.count > 3 ? components[3] * 255.0 : 255.0))
        return Data(rgba)
    }
    
    convenience init?(data: Data) {
        var rgba = [UInt8](repeating: 0, count: 4)
        data.copyBytes(to: &rgba, count: 4)
        self.init(red: CGFloat(rgba[0]) / 255.0,
                  green: CGFloat(rgba[1]) / 255.0,
                  blue: CGFloat(rgba[2]) / 255.0,
                  alpha: CGFloat(rgba[3]) / 255.0)
    }
}
