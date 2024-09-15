//
//  NewPointLine.swift
//  TerraAvengers
//
//  Created by Elliott Yu on 23/10/2023.
//

import Foundation
import SwiftUI

struct GraphLine: Shape{
    var points: [CGPoint]
    var bottomLeft: CGPoint
    var bottomRight: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: bottomLeft)
        path.addLine(to: points[0])
        for i in 1..<points.count - 1{
            path.addCurve(to: points[i],
                          control1:
                            CGPoint(x: points[i-1].x + 20, y: points[i-1].y),
                          control2:
                            CGPoint(x: points[i].x - 20, y: points[i].y))
        
        }
        
        path.addLine(to: bottomRight)
        path.closeSubpath()
        return path
    }
}
