//
//  Texture2DArray.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 08.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum Texture2DArrayError: Error {
    case unacceptableIndex(details: String)
}

public class Texture2DArray: Object, Texture, Usable, Sizeable {
    
    private(set) public var size: CGSize = .zero
    private(set) public var capacity: UInt = 0
    private var bitmapContext: CGContext?
    
    // MARK: - Initializers
    
    private init() throws {
        var name: GLuint = 0
        glGenTextures(1, &name);
        try super.init(name: name)
        
        use()
        enableNPOTSupport()
    }
    
    public convenience init(sizeInPixels: CGSize, capacity: UInt) throws {
        try self.init()
        
        self.capacity = capacity
        size = Converter.points(from: sizeInPixels)
        try validate(size: size)
        
        glTexStorage3D(GLenum(GL_TEXTURE_2D_ARRAY),
                       1, // No mipmaps (1 means that there is only one base image level)
            GLenum(GL_RGBA8), // Internal format
            GLsizei(sizeInPixels.width), // Width
            GLsizei(sizeInPixels.height), // Height
            GLsizei(capacity)) // Number of layers (elements, textures) in the array
    }
    
    public convenience init(size: CGSize, capacity: UInt) throws {
        try self.init()
        try validate(size: size)
        
        self.capacity = capacity
        self.size = size
        
        use()
        enableNPOTSupport()
        
        let realSize = Converter.pixels(from: size)
        glTexStorage3D(GLenum(GL_TEXTURE_2D_ARRAY),
                       1, // No mipmaps (1 means that there is only one base image level)
                       GLenum(GL_RGBA8), // Internal format
                       GLsizei(realSize.width), // Width
                       GLsizei(realSize.height), // Height
                       GLsizei(capacity)) // Number of layers (elements, textures) in the array
    }
    
    // MARK: - Usable Protocol
    
    public func use() {
        glBindTexture(GLenum(GL_TEXTURE_2D_ARRAY), name)
    }
    
    // MARK: - Texture Protocol
    
    func enableNPOTSupport() {
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE);
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST);
        glTexParameteri(GLenum(GL_TEXTURE_2D_ARRAY), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST);
    }
    
    // MARK: - Public methods
    
    public func updateTexture(at index: UInt, withContentsOf view: UIView) throws {
        if view.bounds.size.width != size.width || view.bounds.size.height != size.height {
            throw SizeError.invalidSize(details: "Attempt to update texture in the texture array with a view the size of which (w: \(view.bounds.size.width), h: \(view.bounds.size.width)) doesn't match acceptable size (w: \(size.width), h: \(size.width))")
        }
        
        if index >= capacity {
            throw Texture2DArrayError.unacceptableIndex(details: "Index \(index) exceedes texture array capacity \(capacity)")
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
        
        glTexSubImage3D(GLenum(GL_TEXTURE_2D_ARRAY),
                        0, // Mipmap index (0 stands for base image level)
                        0, 0, GLint(index), // xOffset, yOffset, zOffset (index of texture in the array)
                        GLsizei(realSize.width), GLsizei(realSize.height), 1, // width, height, depth
                        GLenum(GL_RGBA), // Format
                        GLenum(GL_UNSIGNED_BYTE), // Type
                        context.data) // Slice (single texture in the array) data
    }
}
