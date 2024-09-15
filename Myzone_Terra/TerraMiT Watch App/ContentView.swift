//
//  ContentView.swift
//  TerraMiT Watch App
//
//  Created by Elliott Yu on 11/09/2024.
//

import SwiftUI
import TerraRTiOS

struct ContentView: View {
    static var terraRT: Terra? = nil
    
    @State var alertError = false
    @State var currErr = ""
    @State var hrValue = 0
    var body: some View {
        GeometryReader {reader in
            ZStack{
                Color.init(.sRGB, red: 188/255, green: 224/255, blue: 254/255, opacity: 1).ignoresSafeArea(.all)

                HStack{
                    Image(systemName: "heart.fill").resizable().frame(width: 20, height: 20).foregroundColor(.red).padding(.trailing, 10)
                    Text("\(hrValue)").font(.custom("Poppins-Bold", size: 24))
                }
            }
        }
        .onAppear{
            do {
                ContentView.terraRT = try Terra()
                ContentView.terraRT?.connect()
                ContentView.terraRT?.startExercise(forType: .OTHER, completion: { suc, err in
                    if let err = err {
                        currErr = err.localizedDescription
                        alertError = true
                    } else{
                        ContentView.terraRT?.setUpdateHandler(setHr)
                        ContentView.terraRT?.startStream(forDataTypes: Set([.HEART_RATE]), completion: { t, er in
                            if let err = er {
                                alertError = true
                                currErr = err.localizedDescription
                            }
                        })
                    }
                })
            } catch {
                alertError = true
            }
        }.alert(
            "Watch Not Supported",
            isPresented: $alertError
        ) {
            Button("OK") {
                alertError = false
            }
        }
    }
    
    func setHr(_ hr: Update){
        if hr.type != nil && hr.type!.contains("HEART_RATE"){
            hrValue = Int(hr.val ?? 0.0)
            ContentView.terraRT?.sendMessage(["heartrate": hrValue, "time": hr.ts])
        }
    }
    
}

#Preview {
    ContentView()
}
