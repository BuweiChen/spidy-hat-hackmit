//
//  AxisLabels.swift
//  TerraAvengers
//
//  Created by Elliott Yu on 16/10/2023.
//

import Foundation
import SwiftUI

struct YAxisLabel: View {
    let height: CGFloat
    let width: CGFloat
    let numberOfPoints: Int
    
    let points: Int = 5
    let font: Font = .custom("Poppins-Regular", size: 10)

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach((0..<points+1).reversed(), id: \.self) { value in
                Text("\(value * 220/points) ")
                    .font(font)
                    .frame(width: width, height: height / CGFloat(points), alignment: .trailing)
                    .foregroundColor(.init(red: 143/255, green: 157/255, blue: 185/255))
            }
        }.offset(y: (-height / CGFloat(points) / 2) - 8)
    }
}
