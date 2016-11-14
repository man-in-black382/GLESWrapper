//
//  RenderConfiguration.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 11.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum RenderBuffer {
    case color
    case depth
    case stencil
    
    internal var glRepresentation: Int32 {
        switch self {
        case .color: return GL_COLOR_BUFFER_BIT
        case .depth: return GL_DEPTH_BUFFER_BIT
        case .stencil: return GL_STENCIL_BUFFER_BIT
        }
    }
}

public class RenderConfiguration {
    public var viewport: CGRect?
    public var buffersToClear: [RenderBuffer]?
}

public class SinglePassRenderConfiguration<VertexType: Vertex>: RenderConfiguration {
    internal(set) public var vertexArray: VertexArray<VertexType>
    internal(set) public var program: Program
    
    internal init(vertexArray: VertexArray<VertexType>, program: Program) {
        self.vertexArray = vertexArray
        self.program = program
    }
}
