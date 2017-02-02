//
//  Texture.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 08.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

internal protocol Texture {
    func enableNPOTSupport()
    func bitmapContextWith(size: CGSize, scale: CGFloat) -> CGContext?
}

internal extension Texture {
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
