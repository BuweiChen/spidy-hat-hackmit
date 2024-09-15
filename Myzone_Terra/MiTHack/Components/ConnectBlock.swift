//
//  ConnectBlock.swift
//  MiTHack
//
//  Created by Elliott Yu on 13/09/2024.
//

import Foundation
import SwiftUI
import TerraRTiOS

struct ConnectBlock: View {
    @State var connectionType: Connections = .BLE
    @Binding var selected: Bool
    @Binding var rejected: Bool
        
    var bleDescription = "Connect to Bluetooth Low Energy (BLE) devices such as Garmin watches, WHOOP, Chest Straps, Wrist Straps, or provided programmed Bangle JS's!"
    
    var watchDescription = "Connect with your paired Apple Watch. Open the app on your watch to start streaming!"
    
    var body: some View {
        GeometryReader {reader in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: .init(lineWidth: 1))
                    .foregroundColor(rejected ? .red : .black)
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: rejected ? .red.opacity(0.3) : .black.opacity(selected ? 0.3 : 0.1), radius: selected ? 15 : 10)
                VStack {
                    HStack {
                        if connectionType == .BLE {
                            Image("bluetooth").resizable().frame(width: 50, height: 50)
                        } else {
                            Image(systemName: "applewatch").resizable().scaledToFit().frame(height: 50)
                        }
                        Spacer()
                        Image(systemName: "arrowshape.right.circle.fill")
                            .resizable().frame(width: 30, height: 30)
                            .foregroundColor(.accent)
                    }
                    .frame(alignment: .leading)
                    .padding(.top, 50)
                    Spacer()
                    Text(connectionType == .BLE ? bleDescription : watchDescription).font(.custom("Poppins-Regular", size: 14))
                        .padding(.bottom, 50)
                        .multilineTextAlignment(.leading)
                }.frame(width: reader.size.width * 0.8, alignment: .leading)
            }
            .opacity(selected ? 1: 0.8)
            .scaleEffect(selected ? 1.01 : 1)
        }
    }
}

//#Preview {
//    ConnectBlock().frame(height: 300)
//}
