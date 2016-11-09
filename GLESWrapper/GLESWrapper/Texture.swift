//
//  Texture.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 08.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum TextureError: Error {
    case invalidSize(details: String)
}

internal protocol Texture {
    func validate(size: CGSize) throws
    func enableNPOTSupport()
    func bitmapContextWith(size: CGSize, scale: CGFloat) -> CGContext?
}

internal extension Texture {
    func validate(size: CGSize) throws {
        if size.width == 0 || size.height == 0 {
            throw TextureError.invalidSize(details: "Size cannot have dimensions of 0")
        }
    }
    
    func bitmapContextWith(size: CGSize, scale: CGFloat) -> CGContext? {
        let BitsPerComponent = 8
        let ColorSizeInMemory = 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: BitsPerComponent, bytesPerRow: ColorSizeInMemory * Int(size.width), space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        context?.scaleBy(x: scale, y: scale)
        return context
    }
}
