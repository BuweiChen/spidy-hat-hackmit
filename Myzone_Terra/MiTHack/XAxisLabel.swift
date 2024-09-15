//
//  XAxisLabels.swift
//  TerraAvengers
//
//  Created by Elliott Yu on 16/10/2023.
//

import Foundation
import SwiftUI

struct XAxisLabel: View{
    
    @State var dateformatter: DateFormatter = {
       let dateformatter_ = DateFormatter()
        dateformatter_.dateFormat = "h:mm:ss"
        return dateformatter_
    }()
    @State var font: Font = .custom("Poppins-Regular", size: 10)
    
    @Binding var dataPoints: [Datapoint]
    
    let width: CGFloat
    let height: CGFloat
    let numberOfPointsToDisplay: Int
    
    var points: Double = 6.0
    var range: [Date]
    
    
    init(dataPoints: Binding<[Datapoint]>, width: CGFloat, height: CGFloat, numberOfPointsToDisplay: Int) {
        self._dataPoints = dataPoints
        self.width = width
        self.height = height
        self.numberOfPointsToDisplay = numberOfPointsToDisplay
        self.range = []
        guard dataPoints.count > 2 else{
            return
        }
        let first = self._dataPoints.first!.x
        let last = self._dataPoints.last!.x
        let diff = last.wrappedValue.timeIntervalSince1970 - first.wrappedValue.timeIntervalSince1970
        
        if self.dataPoints.count >= numberOfPointsToDisplay{
            let interval = TimeInterval(diff/points)
            for date in stride(from: first.wrappedValue, to: last.wrappedValue, by: interval){
                if range.count == 6{
                    break
                }
                range.append(date)
            }
        }
        else{
            let max = Double(numberOfPointsToDisplay / dataPoints.count) * Double(diff) + first.wrappedValue.timeIntervalSince1970
            for date in stride(from: first.wrappedValue, to: Date(timeIntervalSince1970: max), by: (max - Double(first.wrappedValue.timeIntervalSince1970))/points){
                if range.count == 6{
                    break
                }
                range.append(date)
            }
        }
        
    }
    
    var body: some View {
        LazyHStack(alignment: .top) {
            ForEach(self.range.indices, id: \.self) { index in
                Text("\(dateformatter.string(from: self.range[index]).lowercased())")
                    .font(self.font)
                    .frame(width: width / points, height: height)
                    .foregroundColor(.init(red: 143/255, green: 157/255, blue: 185/255))
            }
        }
    }
}

extension XAxisLabel{
    func font(_ font: Font) -> some View{
        self.font = font
        return self
    }
    
    func setDateFormatter(_ dateformatter: DateFormatter) -> some View{
        self.dateformatter = dateformatter
        return self
    }
}
