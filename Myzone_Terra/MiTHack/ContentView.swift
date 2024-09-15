//
//  ContentView.swift
//  MiTHack
//
//  Created by Elliott Yu on 10/09/2024.
//

import SwiftUI
import TerraRTiOS

public struct TokenPayload: Codable{
    let token: String
}

struct TokenReponse: Codable{
    let token: String?
    let status: String?
}

struct UserIdPayload: Codable {
    let userId: String
    let name: String
}
struct ContentView: View{
    
    static public var terraRT: TerraRT? = nil
    @State var name: String = (UserDefaults.standard.string(forKey: "mit.hack.name") ?? "")
    
    @State var path: [String] = []
    @State var displayScanWidget: Bool = false
    @State var alertError: Bool = false
    @State var connectionType: Connections = .BLE
    
    @State var bleSelected: Bool = false
    @State var watchSelected: Bool = false
    
    @State var fillName: Bool = false
    @State var alertWatchOS: Bool = false
    
    @State var shakeBLE = false
    @State var shakeWatch = false
    
    @State private var invalidRange: NSRange? = nil
    
    var body: some View{
        NavigationStack(path: $path){
            GeometryReader{geometry in
                ZStack{
                    Color.appBackground.ignoresSafeArea(.all)
                    VStack {
                        Text(
                            "Select a Device")
                        .font(Font.custom("Poppins-Bold", size: 16)).padding(.top, 10).padding(.leading, 18)
                        .frame(width: geometry.size.width, height: 24, alignment: .leading)
                        HStack{
                            VStack(alignment: .leading){
                                Text("This uses bluetooth to connect your device to Terra.")
                                    .font(Font.custom("Poppins-Light", size: 14))
                                    .foregroundColor(Color.lightText)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                        }.frame(width: geometry.size.width * 0.9, height: 40)
                            .padding(.top, 20)
                        
                        ZStack {
                            if let invalidRange = invalidRange, !name.isEmpty {
                                AttributedText(inputText: name, invalidRange: invalidRange)
                                    .frame(width: geometry.size.width * 0.9, height: 40)
                                    .offset(x: shakeBLE || shakeWatch ? -10 : 0) // Apply shake effect
                                    .animation(shakeBLE || shakeWatch ? .bouncy.repeatCount(5, autoreverses: true) : .default)
                            }
                            VStack {
                                TextField("What do we call you?", text: $name)
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .background(Color.clear) // Keep the TextField background transparent
                                    .cornerRadius(8)
                                    .frame(width: geometry.size.width * 0.9, height: 40)
                                    .offset(x: shakeBLE || shakeWatch ? -10 : 10) // Apply shake effect to TextField
                                    .animation(shakeBLE || shakeWatch ? .bouncy.repeatCount(5, autoreverses: true) : .default)
                                Rectangle()
                                    .frame(height: 1.5) // Thickness of the underline
                                    .foregroundColor( shakeBLE || shakeWatch ? .red : .gray) // Color of the underline (red if shaking, gray otherwise)
                                    .padding(.bottom, 10)
                                    .frame(width: geometry.size.width * 0.9)
                            }
                        }
                        
                        ConnectBlock(connectionType: .BLE, selected: $bleSelected, rejected: $shakeBLE)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    withAnimation(.easeInOut(duration: 0.2)){
                                        bleSelected = true
                                        watchSelected = false
                                    }
                                }
                                .onEnded { value in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if name == ""{
                                            fillName = true
                                             
                                            shakeBLE = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                                shakeBLE = false
                                                bleSelected = false
                                            }
                                            return
                                        }
                                        UserDefaults.standard.setValue(name, forKey: "mit.hack.name")
                                        let boxFrame = geometry.frame(in: .global)
                                        if boxFrame.contains(value.location) {
                                            ContentView.terraRT = TerraRT(devId: Bundle.main.object(forInfoDictionaryKey: "dev-id") as? String ?? "", referenceId: name, completion: { s in
                                                alertError = !s
                                                
                                                if let userId = ContentView.terraRT?.getUserid(){
                                                    connectionType = .BLE
                                                    displayScanWidget.toggle()
                                                    HTTPRequestClient.Builder()
                                                        .setMethod(.POST)
                                                        .setUrl("https://hackmit.tryterra.co/api/names")
                                                        .withInput(BlankResponse.self)
                                                        .withOutput(String(data: try! JSONEncoder().encode(UserIdPayload(userId: userId, name: name)), encoding: .utf8)!)
                                                        .build()
                                                        .executeRequest()
                                                }
                                                else{
                                                    HTTPRequestClient.Builder()
                                                        .setMethod(.POST)
                                                        .setUrl("https://api.tryterra.co/v2/auth/generateAuthToken")
                                                        .withInput(TokenReponse.self)
                                                        .setHeaders(["dev-id": Bundle.main.object(forInfoDictionaryKey: "dev-id") as? String ?? "", "x-api-key": Bundle.main.object(forInfoDictionaryKey: "x-api-key") as? String ?? ""])
                                                        .build()
                                                        .executeAndGetResult { resp in
                                                            if let resp_ = resp, let token = resp_.token{
                                                                ContentView.terraRT?.initConnection(token: token){success in
                                                                    if success{
                                                                        connectionType = .BLE
                                                                        displayScanWidget.toggle()
                                                                        HTTPRequestClient.Builder()
                                                                            .setMethod(.POST)
                                                                            .setUrl("https://hackmit.tryterra.co/api/names")
                                                                            .withInput(BlankResponse.self)
                                                                            .withOutput(String(data: try! JSONEncoder().encode(UserIdPayload(userId: (ContentView.terraRT?.getUserid())!, name: name)), encoding: .utf8)!)
                                                                            .build()
                                                                            .executeRequest()
                                                                    }
                                                                }
                                                            }
                                                        }
                                                }
                                            })
                                        }
                                        bleSelected = false
                                    }
                                }
                            )
                            .offset(x: shakeBLE ? -7 : 0) // Horizontal shake effect
                            .animation(shakeBLE ? .bouncy.repeatCount(5, autoreverses: true) : .default)
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.35, alignment: .center)
                        
                        ConnectBlock(connectionType: .WATCH_OS, selected: $watchSelected, rejected: $shakeBLE)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            watchSelected = true
                                            bleSelected = false
                                        }
                                    }
                                    .onEnded { value in
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            if name == ""{
                                                fillName = true
                                                shakeWatch = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                                                    shakeWatch = false
                                                    watchSelected = false
                                                }
                                                return
                                            }
                                            UserDefaults.standard.setValue(name, forKey: "mit.hack.name")
                                            let boxFrame = geometry.frame(in: .global)
                                            if boxFrame.contains(value.location) {

                                                ContentView.terraRT = TerraRT(devId: Bundle.main.object(forInfoDictionaryKey: "dev-id") as? String ?? "", referenceId: name, completion: { s in
                                                    alertError = !s
                                                    do {
                                                        try ContentView.terraRT?.connectWithWatchOS()
                                                    } catch {
                                                        alertError = true
                                                        return
                                                    }
                                                    
                                                    if let userId = ContentView.terraRT?.getUserid(){
                                                        connectionType = .WATCH_OS
                                                        alertWatchOS = true
                                                        path.append("streamView")
                                                        HTTPRequestClient.Builder()
                                                            .setMethod(.POST)
                                                            .setUrl("https://hackmit.tryterra.co/api/names")
                                                            .withInput(BlankResponse.self)
                                                            .withOutput(String(data: try! JSONEncoder().encode(UserIdPayload(userId: userId, name: name)), encoding: .utf8)!)
                                                            .build()
                                                            .executeRequest()
                                                    }
                                                    else{
                                                        HTTPRequestClient.Builder()
                                                            .setMethod(.POST)
                                                            .setUrl("https://api.tryterra.co/v2/auth/generateAuthToken")
                                                            .withInput(TokenReponse.self)
                                                            .setHeaders(["dev-id": Bundle.main.object(forInfoDictionaryKey: "dev-id") as? String ?? "", "x-api-key": Bundle.main.object(forInfoDictionaryKey: "x-api-key") as? String ?? ""])
                                                            .build()
                                                            .executeAndGetResult { resp in
                                                                if let resp_ = resp, let token = resp_.token{
                                                                    ContentView.terraRT?.initConnection(token: token){success in
                                                                        if (success){
                                                                            HTTPRequestClient.Builder()
                                                                                .setMethod(.POST)
                                                                                .setUrl("https://hackmit.tryterra.co/api/names")
                                                                                .withInput(BlankResponse.self)
                                                                                .withOutput(String(data: try! JSONEncoder().encode(UserIdPayload(userId: (ContentView.terraRT?.getUserid())!, name: name)), encoding: .utf8)!)
                                                                                .build()
                                                                                .executeRequest()
                                                                            connectionType = .WATCH_OS
                                                                            alertWatchOS = true
                                                                            path.append("streamView")
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                    }

                                                })
                                            }
                                            watchSelected = false
                                        }
                                    }
                                )
                            .offset(x: shakeWatch ? -7 : 0) // Horizontal shake effect
                            .animation(shakeWatch ? .bouncy.repeatCount(5, autoreverses: true) : .default)
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.35, alignment: .center)
                        Spacer()
                    }
                }
            }.navigationDestination(for: String.self){ dest in
                switch dest{
                case "streamView":
                    StreamingView(path: $path, connectionType: $connectionType)
                default:
                    EmptyView()
                }
            }
        }.alert(
            "Error Connect",
            isPresented: $alertError
        ) {
            Button("OK") {
                alertError = false
            }
        }.alert(
            "Apple Watch",
            isPresented: $alertWatchOS
        ) {
            Button("OK") {
                alertWatchOS = false
            }
        } message: {
                Text("Please open the TerraMiT Apple Watch app and agree to asked permissions").font(.custom("Poppins-Regular", size: 15))
        }
        .sheet(isPresented: $displayScanWidget) {
            ContentView.terraRT?.startBluetoothScan(type: .BLE, bluetoothLowEnergyFromCache: false){succ in
                if succ {
                    displayScanWidget.toggle()
                    path.append("streamView")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
