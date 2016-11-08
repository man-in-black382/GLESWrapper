//
//  Texture2D.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 07.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum TextureError: Error {
    case invalidSize
}

public class Texture2D: Object, Usable, Sizeable {
    
    // MARK: - Properties
    
    private var bitmapContext: CGContext?
    internal var pixels: UnsafeMutableRawPointer?
    private(set) public var size: CGSize = .zero

    // MARK: - Initializers
    
    private init() throws {
        var name: GLuint = 0
        glGenTextures(1, &name);
        try super.init(name: name)
    }
    
    public convenience init(size: CGSize) throws {
        if size.width == 0 || size.height == 0 {
            throw TextureError.invalidSize
        }
        
        try self.init()
        
        self.size = size
        use()
        enableNPOTSupport()
        
        let realSize = Converter.pixels(from: size)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA,
                     GLsizei(realSize.width), GLsizei(realSize.height), 0,
                     GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil);
    }
    
    // MARK - Private methods

    private func enableNPOTSupport() {
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST);
    }
    
    private func bitmapContextWith(size: CGSize, scale: CGFloat) -> CGContext? {
        let BitsPerComponent = 8
        let ColorSizeInMemory = 4
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: BitsPerComponent, bytesPerRow: ColorSizeInMemory * Int(size.width), space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        context?.scaleBy(x: scale, y: scale)
        return context
    }
    
    // MARK: - Usable protocol
    
    public func use() {
        glBindTexture(GLenum(GL_TEXTURE_2D), name)
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));
    }
    
    // MARK: - Public methods
    
    public func update(withContentsOf view: UIView) {
        let realSize = Converter.pixels(from: view.bounds.size)
        var sizeChanged: Bool = false
        
        if bitmapContext?.width != Int(realSize.width) || bitmapContext?.height != Int(realSize.height) {
            bitmapContext = bitmapContextWith(size: realSize, scale: UIScreen.main.scale)
            size = view.bounds.size
            sizeChanged = true
        }
    
        guard let context = bitmapContext else {
            return
        }
        
        view.layer.render(in: context)
        
        guard let pixelData = context.data else {
            return
        }
        
        pixels = pixelData
        use()
        
        if sizeChanged {
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA,
                         GLsizei(realSize.width), GLsizei(realSize.height), 0,
                         GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), pixelData);
        } else {
            glTexSubImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA,
                            GLsizei(realSize.width), GLsizei(realSize.height), 0,
                            GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), pixelData)
        }
    }
    
    
}
