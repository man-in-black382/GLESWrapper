//
//  Framebuffer.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 03.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum FramebufferError: Error {
    case missingAttachment(details: String)
}

public enum ColorAttachment {
    case attachment0, attachment1, attachment2, attachment3
    case attachment4, attachment5, attachment6, attachment7
    case attachment8, attachment9, attachment10, attachment11
    case attachment12, attachment13, attachment14, attachment15
    
    internal var glRepresentation: GLenum {
        switch self {
        case .attachment0: return GLenum(GL_COLOR_ATTACHMENT0)
        case .attachment1: return GLenum(GL_COLOR_ATTACHMENT1)
        case .attachment2: return GLenum(GL_COLOR_ATTACHMENT2)
        case .attachment3: return GLenum(GL_COLOR_ATTACHMENT3)
        case .attachment4: return GLenum(GL_COLOR_ATTACHMENT4)
        case .attachment5: return GLenum(GL_COLOR_ATTACHMENT5)
        case .attachment6: return GLenum(GL_COLOR_ATTACHMENT6)
        case .attachment7: return GLenum(GL_COLOR_ATTACHMENT7)
        case .attachment8: return GLenum(GL_COLOR_ATTACHMENT8)
        case .attachment9: return GLenum(GL_COLOR_ATTACHMENT9)
        case .attachment10: return GLenum(GL_COLOR_ATTACHMENT10)
        case .attachment11: return GLenum(GL_COLOR_ATTACHMENT11)
        case .attachment12: return GLenum(GL_COLOR_ATTACHMENT12)
        case .attachment13: return GLenum(GL_COLOR_ATTACHMENT13)
        case .attachment14: return GLenum(GL_COLOR_ATTACHMENT14)
        case .attachment15: return GLenum(GL_COLOR_ATTACHMENT15)
        }
    }
}

public class Framebuffer: Object, Usable, Sizeable {
    
    // MARK: - Properties
    
    private(set) public var size: CGSize = .zero
    internal var colorAttachments = [ColorAttachment: Sizeable]()
    
    // MARK: - Lifecycle
    
    public init(size: CGSize) throws {
        var framebufferName: GLuint = 0
        glGenFramebuffers(1, &framebufferName)
        try super.init(name: framebufferName)
        
        try validate(size: size)
        self.size = size
    }
    
    deinit {
        glDeleteFramebuffers(1, &name)
    }
    
    // MARK: - Usable protocol
    
    public func use() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), name)
        let drawBuffers = colorAttachments.map { (colorAttachment, object) -> GLenum in
            return colorAttachment.glRepresentation
        }
        glDrawBuffers(GLsizei(drawBuffers.count), drawBuffers);
    }
    
    // MARK: - Public
    
    public static func copy(from sourceFramebuffer: Framebuffer,
                            attachment sourceAttachment: ColorAttachment,
                            rectangle sourceRect: CGRect,
                            to destinationFramebuffer: Framebuffer,
                            attachment destinationAttachment: ColorAttachment,
                            rectangle destinationRect: CGRect) throws {
        
        glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), sourceFramebuffer.name)
        glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), destinationFramebuffer.name)
        
        var sourceRectInPixels = Converter.pixels(from: sourceRect)
        // Invert origin Y
        guard let sourceAttachedObject = sourceFramebuffer.colorAttachments[sourceAttachment] else {
            throw FramebufferError.missingAttachment(details: "Attemp to copy from \(sourceAttachment), which doesn't have anything attached to it")
        }
        guard destinationFramebuffer.colorAttachments[destinationAttachment] != nil else {
            throw FramebufferError.missingAttachment(details: "Attemp to copy to \(destinationAttachment), which doesn't have anything attached to it")
        }
        
        // Invert Y origin
        sourceRectInPixels = Converter.inverted(rect: sourceRectInPixels, relativeTo: Converter.pixels(from: sourceAttachedObject.size))
        let destinationRectInPixels = Converter.pixels(from: destinationRect)
                
        glBlitFramebuffer(GLint(sourceRectInPixels.minX), GLint(sourceRectInPixels.minY),
                          GLint(sourceRectInPixels.maxX), GLint(sourceRectInPixels.maxY),
                          GLint(destinationRectInPixels.minX), GLint(destinationRectInPixels.minY),
                          GLint(destinationRectInPixels.maxX), GLint(destinationRectInPixels.maxY),
                          GLbitfield(GL_COLOR_BUFFER_BIT), GLenum(GL_LINEAR))
    }
    
    public func attach(texture: Texture2D, to colorAttachment: ColorAttachment) throws {
        if texture.size.width != size.width || texture.size.height != size.height {
            throw SizeError.invalidSize(details: "Attempt to attach a texture the size of which (w: \(texture.size.width), h: \(texture.size.width)) doesn't match the framebuffer's size (w: \(size.width), h: \(size.width))")
        }
        colorAttachments[colorAttachment] = texture
        use()
        texture.use()
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), colorAttachment.glRepresentation, GLenum(GL_TEXTURE_2D), texture.name, 0)
    }
    
    public func attach(layer: Int, of texture2DArray: Texture2DArray, to colorAttachment: ColorAttachment) throws {
        if texture2DArray.size.width != size.width || texture2DArray.size.height != size.height {
            throw SizeError.invalidSize(details: "Attempt to attach a texture array the size of which (w: \(texture2DArray.size.width), h: \(texture2DArray.size.width)) doesn't match the framebuffer's size (w: \(size.width), h: \(size.width))")
        }
        colorAttachments[colorAttachment] = texture2DArray
        use()
        texture2DArray.use()
        glFramebufferTextureLayer(GLenum(GL_FRAMEBUFFER), colorAttachment.glRepresentation, texture2DArray.name, 0, GLint(layer))
    }
}
