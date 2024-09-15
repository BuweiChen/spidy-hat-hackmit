//
//  StreamingView.swift
//  MiTHack
//
//  Created by Elliott Yu on 10/09/2024.
//

import Foundation
import SwiftUI
import TerraRTiOS
struct StreamingView: View{
    
    @Binding var path: [String]
    @State public var streamValue: Int = 0
    @State public var hrPoints: [Datapoint] = []
    @State var backSelected: Bool = false
    
    @State var isPulsing: Bool = false
    @Binding public var connectionType: Connections
    

    var isoformatterDecoder = ISO8601DateFormatter()
    var minhr: Int {
        get {
            self.$hrPoints.count > 1 ?
            Int(self.$hrPoints.min { b1, b2 in
                b1.wrappedValue.y < b2.wrappedValue.y
            }?.wrappedValue.y ?? 0.0)
            : 0
        }
    }
    
    var maxHr: Int {
        get {
            self.$hrPoints.count > 1 ?
            Int(self.$hrPoints.max { b1, b2 in
                b2.wrappedValue.y > b1.wrappedValue.y
            }?.wrappedValue.y ?? 0.0)
            : 0
        }
    }
    
    var avgHr: Int{
        get {
            self.$hrPoints.count > 0 ?
            Int(self.$hrPoints.reduce(0.0, { partialResult, d1 in
                partialResult + d1.wrappedValue.y
            })/Double(self.hrPoints.count))
            : 0
        }
    }
    
    var body: some View{
        GeometryReader{ geometry in
            VStack(alignment: .center, spacing: 0){
                ZStack{
                    Text("Heartrate").font(Font.custom("Poppins-Bold", size: 16))
                    HStack{
                        Image(systemName: "arrowshape.backward").resizable().scaledToFit().frame(height: 16)
                        .opacity(backSelected ? 0.6 : 1)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    backSelected = true
                                }
                                .onEnded { value in
                                    if connectionType == .WATCH_OS {
                                        ContentView.terraRT?.stopWatchOSWorkout(completion: { s in
                                            ContentView.terraRT?.stopRealtime(type: connectionType)
                                            ContentView.terraRT?.disconnect(type: connectionType)
                                        })
                                    } else {
                                        ContentView.terraRT?.stopRealtime(type: connectionType)
                                        ContentView.terraRT?.disconnect(type: connectionType)
                                    }
                                    path = []
                                    backSelected = false
                                })
                        .padding(.leading, 25)
                        Spacer()
                    }
                }.padding(.top, 10)
                    .frame(width: geometry.size.width, height: 24, alignment: .center)
                Spacer()
                ZStack(alignment: .center){
                    Circle()
                        .fill(Color.init(.sRGB, red: 188/255, green: 224/255, blue: 254/255, opacity: 0.3))
                        .frame(width: isPulsing ? geometry.size.width * 0.75 : geometry.size.width * 0.72,
                               height: isPulsing ? geometry.size.width * 0.75 : geometry.size.width * 0.72)
                        .animation(Animation.easeInOut(duration: 0.5), value: isPulsing)

                    // Middle Circle
                    Circle()
                        .fill(Color.init(.sRGB, red: 188/255, green: 224/255, blue: 254/255, opacity: 0.5))
                        .frame(width: isPulsing ? geometry.size.width * 0.65 : geometry.size.width * 0.6,
                               height: isPulsing ? geometry.size.width * 0.65 : geometry.size.width * 0.6)
                        .animation(Animation.easeInOut(duration: 0.5), value: isPulsing)

                    // Inner Circle
                    Circle()
                        .fill(Color.init(.sRGB, red: 188/255, green: 224/255, blue: 254/255, opacity: 1))
                        .frame(width: isPulsing ? geometry.size.width * 0.55 : geometry.size.width * 0.5,
                               height: isPulsing ? geometry.size.width * 0.55 : geometry.size.width * 0.5)
                        .animation(Animation.easeInOut(duration: 0.5), value: isPulsing)
                    HStack{
                        Text("\(Int(self.hrPoints.last?.y ?? 0.0))")
                            .font(.custom("Poppins-Bold", size: 63))
                            .foregroundColor(Color.init(.sRGB, red:48/255, green:164/255, blue: 251/255, opacity: 1))
                        VStack(alignment: .leading, spacing: 0 ){
                            Text("BPM")
                                .font(.custom("Poppins-Regular", size: 21))
                            HStack(spacing: 3){
                                Image("heart")
                                if let lastHr = hrPoints.last, lastHr.y >= 150 {
                                    Text("Bruh")
                                        .font(.custom("Poppins-Regular", size: 12.27))
                                } else {
                                    Text("Normal")
                                        .font(.custom("Poppins-Regular", size: 12.27))
                                }
                            }
                        }
                    }
                }.padding(.top, 24)
                    .frame(height: geometry.size.height * 0.5)
                Spacer()
                VStack{
                    LineGraph(datapoints: self.$hrPoints ,width: geometry.size.width * 0.9, height: geometry.size.height*0.30)
                        .background(Color.init(.sRGB, red: 248/255, green: 250/255, blue: 255/255, opacity: 1))
                }.padding([.top, .bottom], 20)
                    .frame(alignment: .center)
                HStack{
                    ZStack{
                        Rectangle()
                            .fill(.white)
                            .frame(width: 83, height: 50)
                            .cornerRadius(9)
                        VStack{
                            HStack{
                                Text("\(self.avgHr)")
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .foregroundColor(Color.init(.sRGB, red:48/255, green:164/255, blue: 251/255, opacity: 1))
                                Text("BPM")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color.init(.sRGB, red: 143/255, green: 157/255, blue: 185/255, opacity: 1))
                            }
                            Text("Avg")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color.init(.sRGB, red: 143/255, green: 157/255, blue: 185/255, opacity: 1))
                        }
                    }
                    Spacer()
                    ZStack{
                        Rectangle()
                            .fill(.white)
                            .frame(width: 83, height: 50)
                            .cornerRadius(9)
                        VStack{
                            HStack{
                                Text("\(self.minhr)")
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .foregroundColor(Color.init(.sRGB, red:48/255, green:164/255, blue: 251/255, opacity: 1))
                                Text("BPM")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color.init(.sRGB, red: 143/255, green: 157/255, blue: 185/255, opacity: 1))
                            }
                            Text("Min")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color.init(.sRGB, red: 143/255, green: 157/255, blue: 185/255, opacity: 1))
                        }
                    }
                    Spacer()
                    ZStack{
                        Rectangle()
                            .fill(.white)
                            .frame(width: 83, height: 50)
                            .cornerRadius(9)
                        VStack{
                            HStack{
                                Text("\(self.maxHr)")
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .foregroundColor(Color.init(.sRGB, red:48/255, green:164/255, blue: 251/255, opacity: 1))
                                Text("BPM")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundColor(Color.init(.sRGB, red: 143/255, green: 157/255, blue: 185/255, opacity: 1))
                            }
                            Text("Max")
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundColor(Color.init(.sRGB, red: 143/255, green: 157/255, blue: 185/255, opacity: 1))
                        }
                    }
                }.frame(width: geometry.size.width * 0.8, alignment: .center)
            }
        }.navigationBarBackButtonHidden(true)
        .background(Color.init(.sRGB, red: 248/255, green: 250/255, blue: 255/255, opacity: 1), ignoresSafeAreaEdges: .all)
        .onAppear{
            HTTPRequestClient.Builder()
                .setMethod(.POST)
                .setUrl("https://ws.tryterra.co/auth/user?id=\(ContentView.terraRT?.getUserid() ?? "")")
                .withInput(TokenReponse.self)
                .setHeaders(["dev-id": Bundle.main.object(forInfoDictionaryKey: "dev-id") as? String ?? "", "x-api-key": Bundle.main.object(forInfoDictionaryKey: "x-api-key") as? String ?? ""])
                .build()
                .executeAndGetResult { resp in
                    
                    if let resp_ = resp, let token = resp_.token{
                        ContentView.terraRT?.startRealtime(type: connectionType, dataType: [.HEART_RATE], token: token){update in
                                if let hr = update.val, update.type != nil && update.type!.contains("HEART_RATE"){
                                    self.hrPoints.append(Datapoint(y: hr, x: self.isoformatterDecoder.date(from: update.ts!)!))
                                    if self.hrPoints.count > 11{
                                        self.hrPoints.removeFirst()
                                    }
                                    isPulsing = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(0.5)){
                                        isPulsing = false
                                    }
                                }
                            }
                    }
                }
        }
        .onChange(of: connectionType) { _ in
            HTTPRequestClient.Builder()
                .setMethod(.POST)
                .setUrl("https://ws.tryterra.co/auth/user?id=\(ContentView.terraRT?.getUserid() ?? "")")
                .withInput(TokenReponse.self)
                .setHeaders(["dev-id": Bundle.main.object(forInfoDictionaryKey: "dev-id") as? String ?? "", "x-api-key": Bundle.main.object(forInfoDictionaryKey: "x-api-key") as? String ?? ""])
                .build()
                .executeAndGetResult { resp in
                    if let resp_ = resp, let token = resp_.token{
                        ContentView.terraRT?.startRealtime(type: connectionType, dataType: [.HEART_RATE], token: token){update in
                            if let hr = update.val, update.type != nil && update.type!.contains("HEART_RATE"){
                                self.hrPoints.append(Datapoint(y: hr, x: self.isoformatterDecoder.date(from: update.ts!)!))
                                if self.hrPoints.count > 11{
                                    self.hrPoints.removeFirst()
                                }
                                isPulsing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(0.5)){
                                    isPulsing = false
                                }
                            }
                        }
                    }
                }
        }
    }
}
