//
//  Texture2D.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 07.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public class Texture2D: Object, Texture, Usable, Sizeable {
    
    // MARK: - Properties
    
    private var bitmapContext: CGContext?
    private(set) public var size: CGSize = .zero

    // MARK: - Initializers
    
    private init() throws {
        var name: GLuint = 0
        glGenTextures(1, &name);
        try super.init(name: name)
    }
    
    public convenience init(size: CGSize) throws {
        try self.init()
        try validate(size: size)
        
        self.size = size
        
        use()
        enableNPOTSupport()
        
        let realSize = Converter.pixels(from: size)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA,
                     GLsizei(realSize.width), GLsizei(realSize.height), 0,
                     GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), nil);
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
            throw TextureError.invalidSize(details: "Attempt to update texture with a view the size of which (w: \(view.bounds.size.width), h: \(view.bounds.size.width)) exceeds acceptable size (w: \(size.width), h: \(size.width))")
        }
        
        let realSize = Converter.pixels(from: view.bounds.size)
        
        if bitmapContext == nil {
            bitmapContext = bitmapContextWith(size: realSize, scale: UIScreen.main.scale)
        }
        
        guard let context = bitmapContext else {
            return
        }
        
        view.layer.render(in: context)
        use()
        
        glEnable(GLenum(GL_BLEND));
        glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA));

        glTexSubImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA,
                        GLsizei(realSize.width), GLsizei(realSize.height), 0,
                        GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), context.data)
    }
}
