//
//  WavefrontVertex.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 27.01.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import GLKit

public class WavefrontVertex: Vertex {

    public static var attributeLayouts: [VertexAttributeLayout] {
        return [VertexAttributeLayout(location: 0, memorySize: GLKVector4.memorySize),
                VertexAttributeLayout(location: 1, memorySize: GLKVector3.memorySize),
                VertexAttributeLayout(location: 2, memorySize: GLKVector3.memorySize)]
    }
    
    public static var memorySize: Int {
        return MemoryLayout<GLKVector4>.size + MemoryLayout<GLKVector3>.size + MemoryLayout<GLKVector3>.size
    }

    public var primitiveSequence: [GLfloat] {
        var sequence = position.primitiveSequence
        sequence.append(contentsOf: textureCoordinates.primitiveSequence)
        sequence.append(contentsOf: normal.primitiveSequence)
        return sequence
    }
    
    public var position: GLKVector4
    public var normal: GLKVector3
    public var textureCoordinates: GLKVector3
    
    init(position: GLKVector4 = GLKVector4(v: (0.0, 0.0, 0.0, 1.0)),
         normal: GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0)),
         textureCoordinates: GLKVector3 = GLKVector3(v: (0.0, 0.0, 0.0))) {
        
        self.position = position
        self.normal = normal
        self.textureCoordinates = textureCoordinates
    }
}
