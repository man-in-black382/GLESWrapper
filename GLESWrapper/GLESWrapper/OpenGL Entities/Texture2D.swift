//
//  Texture2D.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 07.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import GLKit

public class Texture2D: Object, Texture, Usable, Sizeable {
    
    // MARK: - Properties
    
    private var bitmapContext: CGContext?
    private(set) public var size: CGSize = .zero

    // MARK: - Initializers
    
    private init() throws {
        var name: GLuint = 0
        glGenTextures(1, &name);
        try super.init(name: name)
        
        use()
        enableNPOTSupport()
    }
    
    public convenience init(sizeInPixels: CGSize) throws {
        try self.init()
        size = Converter.points(from: sizeInPixels)
        try validate(size: size)
        
        glTexStorage2D(GLenum(GL_TEXTURE_2D), 1, GLenum(GL_RGBA8), GLsizei(sizeInPixels.width), GLsizei(sizeInPixels.height))
    }
    
    public convenience init(size: CGSize) throws {
        try self.init()
        try validate(size: size)
        
        self.size = size

        let realSize = Converter.pixels(from: size)
        glTexStorage2D(GLenum(GL_TEXTURE_2D), 1, GLenum(GL_RGBA8), GLsizei(realSize.width), GLsizei(realSize.height))
    }
    
    public init(resourceName: String, bundle: Bundle = Bundle.main) throws {
        guard let filePath = bundle.path(forResource: resourceName, ofType: nil) else {
            throw ResourceLoadingError.fileNotFound(fileName: resourceName)
        }
        
        let textureInfo = try GLKTextureLoader.texture(withContentsOfFile: filePath, options: nil)
        try super.init(name: textureInfo.target)
        size = CGSize(width: Int(textureInfo.width), height: Int(textureInfo.height))
        try validate(size: size)
    }
    
    deinit {
        glDeleteTextures(1, &name)
    }
    
    // MARK: - Usable protocol
    
    public func use() {
        glBindTexture(GLenum(GL_TEXTURE_2D), name)
    }
    
    // MARK: - Texture Protocol
    
    func enableNPOTSupport() {
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST);
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST);
    }
    
    // MARK: - Public methods
    
    public func update(withContentsOf view: UIView) throws {
        if view.bounds.size.width != size.width || view.bounds.size.height != size.height {
            throw SizeError.invalidSize(details: "Attempt to update texture with a view the size of which (w: \(view.bounds.size.width), h: \(view.bounds.size.width)) exceeds acceptable size (w: \(size.width), h: \(size.width))")
        }
        
        let realSize = Converter.pixels(from: view.bounds.size)
        
        if let context = bitmapContext {
            context.clear(CGRect(origin: .zero, size: CGSize(width: context.width, height: context.height)))
        } else {
            bitmapContext = bitmapContextWith(size: realSize, scale: UIScreen.main.scale)
        }

        guard let context = bitmapContext else {
            return
        }
        
        use()
        
        view.layer.render(in: context)
        
        glTexSubImage2D(GLenum(GL_TEXTURE_2D),
                        0, // Mipmap level
                        0, 0, // Origin x, y
                        GLsizei(realSize.width), GLsizei(realSize.height), // Width, height
                        GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), context.data) // Format, type, pixel data
    }
}
