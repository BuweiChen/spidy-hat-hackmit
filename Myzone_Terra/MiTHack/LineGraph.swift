//
//  LineGraph.swift
//  TerraAvengers
//
//  Created by Elliott Yu on 16/10/2023.
//

import Foundation
import SwiftUI

struct LineGraph: View {
    let width: CGFloat
    let height: CGFloat
    let numberOfPoints: Int = 10
    
    @Binding var dataPoints: [Datapoint]
    
    @State private var _xAxisHeight: CGFloat = 30
    @State private var _yAxisWidth: CGFloat = 30
    @State private var _backgroundColor: Color = Color.init(.sRGB, red: 248/255, green: 250/255, blue: 255/255, opacity: 1)
    @State private var _xGridlineCount: Int = 0
    @State private var _yGridlineCount: Int = 5
    
    public init(datapoints: Binding<[Datapoint]>, width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
        self._dataPoints = datapoints
    }
    
    var computedPoints: [CGPoint]{
        get {
            let height = self.height - self._xAxisHeight
            let width = (self.width - self._yAxisWidth - 20)/CGFloat(numberOfPoints)
            return calculatePoints(height: height, width: width, dataPoints: self.dataPoints)
        }
    }

    var body: some View{
        ZStack(alignment: .topLeading){
            self._backgroundColor.ignoresSafeArea(.all)
            
            if self._xGridlineCount > 0 || self._yGridlineCount > 0{
                Gridline(height: height, width: width, yGridlineCount: self._yGridlineCount, xGridlineCount: _xGridlineCount, xAxisHeight: self._xAxisHeight, yAxisWidth: self._yAxisWidth)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
            
            // X-Axis
            Path { path in
                path.move(to: CGPoint(x: self._yAxisWidth, y: height - self._xAxisHeight))
                path.addLine(to: CGPoint(x: self.width, y: height - self._xAxisHeight))
            }.stroke(Color.gray.opacity(0.3), lineWidth: 1)
            
            XAxisLabel(dataPoints: self.$dataPoints, width: self.width - self._yAxisWidth, height: self._xAxisHeight, numberOfPointsToDisplay: self.numberOfPoints).offset(y: self.height-self._xAxisHeight)

            
//            // Y-Axis
//            Path { path in
//                path.move(to: CGPoint(x: self._yAxisWidth, y: 0))
//                path.addLine(to: CGPoint(x: self._yAxisWidth, y: height - self._xAxisHeight))
//                
//            }.stroke(Color.gray.opacity(0.3), lineWidth: 1)
            
            YAxisLabel(height: self.height - self._xAxisHeight, width: self._yAxisWidth, numberOfPoints: self.numberOfPoints).offset(x: width * 0.92)
            
            if self.dataPoints.count > 1 {
                // Line Graph
                Path { path in
                    let points = computedPoints
                    
                    path.move(to: points.first!)
                    for i in 1..<points.count - 1{
                        path.addCurve(to: points[i],
                                      control1:
                                        CGPoint(x: points[i-1].x + 20, y: points[i-1].y),
                                      control2:
                                        CGPoint(x: points[i].x - 20, y: points[i].y))
                        
                    }
                    
                }.stroke(.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .overlay(
                        GraphLine(points: computedPoints, bottomLeft: CGPoint(x: self._yAxisWidth, y: self.height - self._xAxisHeight), bottomRight: CGPoint(x: self.computedPoints[self.dataPoints.count - 2].x, y: self.height-self._xAxisHeight))
                            .fill(LinearGradient(colors: [.init(red: 24/255, green: 160/255, blue: 251/255, opacity: 0.2), .white], startPoint: .top, endPoint: .bottom)))
            
                NewPointLine(from: computedPoints[dataPoints.count - 2] , to: computedPoints.last!).stroke(.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .overlay{
                        NewPointLineClosed(from: computedPoints[dataPoints.count - 2] , to: computedPoints.last!, bottomHeight: self.height - self._yAxisWidth).fill(LinearGradient(colors: [.init(red: 24/255, green: 160/255, blue: 251/255, opacity: 0.2), .white], startPoint: .top, endPoint: .bottom))
                    }
            }
            
        }.background(Color.init(.sRGB, red: 248/255, green: 250/255, blue: 255/255, opacity: 1), ignoresSafeAreaEdges: .all)
    }
    
    func calculatePoints(height: CGFloat, width: CGFloat, dataPoints: [Datapoint]) ->  [CGPoint] {
        if dataPoints.count == 0 {
            return []
        }
        
        let maxDataValue = 220
        let stepX = width
        let stepY = height / CGFloat(maxDataValue)

        return dataPoints.enumerated().map { index, data in
            let x = stepX * CGFloat(index) + self._yAxisWidth
            let y = height - stepY * data.y
            return CGPoint(x: x, y: y)
        }
    }
}

extension LineGraph{
    // Properties
    func backgroundColor(_ color: Color) -> LineGraph {
        self._backgroundColor = color
        return self
    }
    
    func gridLines(_ xGridlineCount: Int, _ yGridlineCount: Int) -> LineGraph{
        self._xGridlineCount = xGridlineCount
        self._yGridlineCount = yGridlineCount
        return self
    }
    
    mutating func xAxisHeight(_ height: CGFloat) -> some View{
        self._xAxisHeight = height
        return self
    }
    
    mutating func yAxisWidth(_ width: CGFloat) -> some View{
        self._yAxisWidth = width
        return self
    }
}


struct Linegraph_Previews: PreviewProvider {
    static var previews: some View {
        @State var dataPoints: [Datapoint] = generateRandomData(1)
        LineGraph(datapoints: $dataPoints, width: CGFloat(350), height: CGFloat(200))
            .gridLines(10, 10)
    }
}
