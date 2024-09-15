//
//  NewPointLine.swift
//  TerraAvengers
//
//  Created by Elliott Yu on 23/10/2023.
//

import Foundation
import SwiftUI

struct NewPointLine: Shape{
    var from: CGPoint
    var to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        path.addCurve(to: to, control1: CGPoint(x: from.x + 20, y: from.y), control2: CGPoint(x: to.x - 20, y: to.y))
        path.addEllipse(in: CGRect(x: to.x, y: to.y - 5, width: 10, height: 10))
        return path
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { return AnimatablePair(to.x, to.y) }
        set { to.x = newValue.first
            to.y = newValue.second}
    }
}


struct NewPointLineClosed: Shape{
    var from: CGPoint
    var to: CGPoint
    
    var bottomHeight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bottomLeft =  CGPoint(x: from.x, y: bottomHeight)
        let bottomRight = CGPoint(x: to.x, y: bottomHeight)
        path.move(to: bottomLeft)
        path.addLine(to: from)
        path.addCurve(to: to, control1: CGPoint(x: from.x + 15, y: from.y), control2: CGPoint(x: to.x - 15, y: to.y))
        path.addLine(to: bottomRight)
        path.closeSubpath()
        return path
    }

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { return AnimatablePair(to.x, to.y) }
        set { to.x = newValue.first
            to.y = newValue.second}
    }
}

