//
//  Date.swift
//  MiTHack
//
//  Created by Elliott Yu on 10/09/2024.
//

import Foundation

extension Date{
     func formatToHumanReadable() -> String{
        let formatter = DateFormatter()
         formatter.dateFormat = "MMM d, h:mm a"

        return formatter.string(from: self)
    }
    
    func toDayMonthDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: self)
    }
    
    func toDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
}
