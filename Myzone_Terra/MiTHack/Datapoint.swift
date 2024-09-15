//
//  Datapoint.swift
//  TerraAvengers
//
//  Created by Elliott Yu on 16/10/2023.
//

import Foundation

struct Datapoint: Codable, Identifiable, Hashable{
    var id: UUID = UUID()
    
    var y: Double
    var x: Date
}
