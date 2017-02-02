//
//  VertexArray.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 07.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import Foundation
import GLKit

enum VertexArrayError: Error {
    case sizeMismatch(details: String)
}

public class VertexArray<VertexType: Vertex>: Object, Usable {
    
    // MARK - Properties
    
    internal var vertices: [VertexType]
    internal var indices: [GLushort]
    private let vertexDataBuffer: GLuint
    private let vertexIndicesBuffer: GLuint
    
    // MARK - Lifecycle
    
    public init(vertices: [VertexType], indices: [GLushort]) throws {
        
        // Generate GL objects

        var arrayName: GLuint = 0
        glGenVertexArrays(1, &arrayName)
        glBindVertexArray(arrayName)
        
        var dataBuffer: GLuint = 0
        var indicesBuffer: GLuint = 0
        
        glGenBuffers(1, &dataBuffer)
        glGenBuffers(1, &indicesBuffer)
        
        vertexDataBuffer = dataBuffer
        vertexIndicesBuffer = indicesBuffer
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexDataBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vertexIndicesBuffer)
        
        // Init buffers
        
        self.vertices = vertices
        self.indices = indices
        
        let verticesPrimitiveSequence = vertices.flatMap({ $0.primitiveSequence })
        
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * verticesPrimitiveSequence.count, verticesPrimitiveSequence, GLenum(GL_DYNAMIC_DRAW))
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLushort>.size * indices.count, indices, GLenum(GL_STATIC_DRAW))
        
        var offset = 0
        for layout in VertexType.attributeLayouts {
            glEnableVertexAttribArray(GLuint(layout.location));
            glVertexAttribPointer(GLuint(layout.location), GLint(layout.memorySize / MemoryLayout<GLfloat>.size), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(VertexType.memorySize), UnsafeRawPointer(bitPattern: offset));
            offset += layout.memorySize
        }
        
        try super.init(name: arrayName)
    }
    
    deinit {
        glDeleteVertexArrays(1, &name)
        glDeleteBuffers(1, [vertexIndicesBuffer, vertexDataBuffer])
    }
    
    // MARK - Public
    
    public func replaceVertex(at position: Int, with vertex: VertexType) throws {
        try replaceVertices(in: position...position, with: [vertex])
    }
    
    public func replaceVertices(in range: ClosedRange<Int>, with vertices: [VertexType]) throws {
        guard range.count == vertices.count else {
            throw VertexArrayError.sizeMismatch(details: "Size of the range (\(range.count)) doesn't match the amount of vertices (\(vertices.count))")
        }
        
        guard vertices.count > 0 else {
            return
        }
        
        self.vertices.replaceSubrange(range, with: vertices)
        let vertex = vertices.first!
//        glBufferSubData(GLenum(GL_ARRAY_BUFFER), range.lowerBound * vertex.memorySize,
//                        range.count * vertex.memorySize, vertices.flatMap { $0.decomposed })
    }
    
    // MARK - Usable protocol
    
    public func use() {
        glBindVertexArray(name)
    }
}
