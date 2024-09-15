//
//  Gridline.swift
//  TerraAvengers
//
//  Created by Elliott Yu on 16/10/2023.
//

import Foundation
import SwiftUI

struct Gridline: Shape{
    let height: CGFloat
    let width: CGFloat
    
    let yGridlineCount: Int
    let xGridlineCount: Int
    let xAxisHeight: CGFloat
    let yAxisWidth: CGFloat
    
    init(height: CGFloat, width: CGFloat, yGridlineCount: Int, xGridlineCount: Int, xAxisHeight: CGFloat, yAxisWidth: CGFloat){
        self.height = height
        self.width = width
        self.xAxisHeight = xAxisHeight
        self.yAxisWidth = yAxisWidth
        self.yGridlineCount = yGridlineCount
        self.xGridlineCount = xGridlineCount
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if yGridlineCount > 0 {
            let stepY = (self.height - xAxisHeight) / CGFloat(yGridlineCount)
            for i in stride(from: 0, through: height - xAxisHeight, by: stepY) {
                path.move(to: CGPoint(x: self.yAxisWidth, y: i))
                path.addLine(to: CGPoint(x: self.width , y: i))
            }
        }
        if xGridlineCount > 0 {
            let stepX = (self.width - yAxisWidth) / CGFloat(xGridlineCount)
            for j in stride(from: yAxisWidth, through: width, by: stepX){
                path.move(to: CGPoint(x: j, y: 0))
                path.addLine(to: CGPoint(x: j, y: height-xAxisHeight))
            }
        }
        return path
    }
}
