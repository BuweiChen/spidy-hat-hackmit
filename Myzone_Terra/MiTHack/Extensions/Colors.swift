//
//  Colors.swift
//  MiTHack
//
//  Created by Elliott Yu on 10/09/2024.
//

import Foundation
import SwiftUI

extension Color{
    public static var appAccentLight: Color{
        Color.init(.sRGB, red: 188/255, green: 224/255, blue: 254/255, opacity: 1)
    }
    
    public static var appTextColor: Color{
        Color.init(.sRGB, red: 30/255, green: 41/255, blue: 58/255, opacity: 1)
    }
    
    public static var lightGray: Color{
        Color.init(.sRGB, red: 217/255, green: 217/255, blue: 217/255, opacity: 1)
    }
    
    public static var appBackground: Color{
        Color.init(.sRGB, red: 188/255, green: 224/255, blue: 254/255, opacity: 1)
    }
    
    public static var darkBackground: Color{
        Color.init(.sRGB, red: 30/255, green: 41/255, blue: 58/255, opacity: 1)
    }
    
    public static var lightBlue: Color{
        Color.init(.sRGB, red: 245/255, green: 249/255, blue: 1, opacity: 1)
    }
    public static var blockShadow: Color{
        Color.init(.sRGB, white: 0, opacity: 0.1)
}
    
    public static var lightText: Color{
        Color.init(.sRGB, red: 102/255, green: 102/255, blue: 102/255, opacity: 1)
    }

}

