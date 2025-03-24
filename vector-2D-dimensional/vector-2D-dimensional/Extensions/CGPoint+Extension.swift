//
//  CGPoint+Extension.swift
//  vector-2D-dimensional
//
//  Created by Александр Янчик on 24.03.25.
//

import CoreGraphics


extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    
    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    func dot(_ other: CGPoint) -> CGFloat {
        x * other.x + y * other.y
    }
    
    func norm() -> CGFloat {
        CGFloat(hypot(Double(x), Double(y)))
    }
    
    func normalized() -> CGPoint {
        self / norm()
    }
}
