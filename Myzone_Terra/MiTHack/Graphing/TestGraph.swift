//
//  TestGraph.swift
//  TerraAvengers
//
//  Created by Daniel Saisani on 18/10/2023.
//

import SwiftUI


struct TestLineGraph: View {
    let width: CGFloat
    let height: CGFloat
    let numberOfPoints: Int = 30
    
    @State private var dataPoints: [Datapoint] = []
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Path { path in
                guard let firstPoint = dataPoints.first else { return }
                let scaleX = width / CGFloat(numberOfPoints)
                let scaleY = height / CGFloat(dataPoints.map { $0.y }.max() ?? 1)
                path.move(to: CGPoint(x: 0, y: height - CGFloat(firstPoint.y) * scaleY))
                
                for point in dataPoints {
                    let x = CGFloat(dataPoints.firstIndex(where: { $0.id == point.id }) ?? 0) * scaleX
                    let y = height - CGFloat(point.y) * scaleY
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke()
        }
        .onReceive(timer) { _ in
            updateData()
        }
        .onAppear {
            for i in 0..<numberOfPoints {
                let value = Double.random(in: 50...300)
                let time = Date().addingTimeInterval(Double(i))
                dataPoints.append(Datapoint(y: value, x: time))
            }
        }
    }
    
    func updateData() {
        let value = Double.random(in: 50...300)
        let time = Date()
        withAnimation {
            dataPoints.append(Datapoint(y: value, x: time))
            dataPoints = Array(dataPoints.suffix(numberOfPoints))
        }
    }

}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        TestLineGraph(width: 350, height: 200)
    }
}
