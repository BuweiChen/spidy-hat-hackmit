//
//  AttributedText.swift
//  MiTHack
//
//  Created by Elliott Yu on 13/09/2024.
//

import Foundation
import SwiftUI

struct AttributedText: View {
    let inputText: String
    let invalidRange: NSRange
    
    var body: some View {
        let attributedString = NSMutableAttributedString(string: inputText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: invalidRange)
        
        return Text(AttributedString(attributedString))
            .font(.body)
    }
}
