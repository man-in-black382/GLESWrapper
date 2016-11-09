//
//  Renderer.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 03.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import GLKit

public enum DrawPattern {
    case triangles
    case triangleStrip
    case triangleFan
    
    internal var glRepresentation: GLenum {
        switch self {
        case .triangles: return GLenum(GL_TRIANGLES)
        case .triangleStrip: return GLenum(GL_TRIANGLE_STRIP)
        case .triangleFan: return GLenum(GL_TRIANGLE_FAN)
        }
    }
}

public class Renderer<VertexType: Vertex> {
    
    // MARK: - Properties
    
    private let program: Program
    private let vertexArray: VertexArray<VertexType>
    private let drawPattern: DrawPattern
    
    // MARK: - Lifecycle
    
    public init(program: Program, vertexArray: VertexArray<VertexType>, drawPattern: DrawPattern) {
        self.program = program
        self.vertexArray = vertexArray
        self.drawPattern = drawPattern
    }
    
    // MARK: - Private
    
    private func render(withConfiguration configuration: ((VertexArray<VertexType>, Program) -> Void)?) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        vertexArray.use()
        program.use()
        if let configuration = configuration {
            configuration(vertexArray, program)
        }
        glDrawElements(drawPattern.glRepresentation, GLsizei(vertexArray.vertices.count), GLenum(GL_UNSIGNED_SHORT), nil);
    }
    
    // MARK: - Public
    
    public func renderOnScreen(glkView: GLKView, configuration: ((VertexArray<VertexType>, Program) -> Void)?) {
        glkView.bindDrawable()
        render(withConfiguration: configuration)
    }
    
    public func renderOffscreen(framebuffer: Framebuffer, configuration: ((VertexArray<VertexType>, Program) -> Void)?) {
        framebuffer.use()
        let drawBuffers = framebuffer.colorAttachments.map { (colorAttachment, object) -> GLenum in
            return colorAttachment.glRepresentation
        }
        glDrawBuffers(GLsizei(drawBuffers.count), drawBuffers);
        render(withConfiguration: configuration)
    }
}
