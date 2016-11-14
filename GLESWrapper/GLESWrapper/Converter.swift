//
//  Converter.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 07.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import UIKit

internal class Converter {
    internal static func pixels(from size: CGSize) -> CGSize {
        let scale = UIScreen.main.nativeScale
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    internal static func points(from size: CGSize) -> CGSize {
        let scale = UIScreen.main.nativeScale
        return CGSize(width: size.width / scale, height: size.height / scale)
    }
    
    internal static func pixels(from rect: CGRect) -> CGRect {
        let scale = UIScreen.main.nativeScale
        return CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale,
                      width: rect.size.width * scale, height: rect.size.height * scale)
    }
    
    internal static func points(from rect: CGRect) -> CGRect {
        let scale = UIScreen.main.nativeScale
        return CGRect(x: rect.origin.x / scale, y: rect.origin.y / scale,
                      width: rect.size.width / scale, height: rect.size.height / scale)
    }
    
    internal static func inverted(rect: CGRect, relativeTo size: CGSize) -> CGRect {
        var rect = rect
        rect.origin.y = size.height - rect.size.height - rect.origin.y
        return rect
    }
}
