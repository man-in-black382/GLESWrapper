//
//  2DLightingSceneVertex.swift
//  GLESWrapperUsageExamples
//
//  Created by Pavlo Muratov on 30.01.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import GLKit
import GLESWrapper

class FlatLightingVertex: Vertex {
    
    public static var attributeLayouts: [VertexAttributeLayout] {
        return [VertexAttributeLayout(location: 0, memorySize: GLKVector4.memorySize),
                VertexAttributeLayout(location: 1, memorySize: GLKVector2.memorySize)]
    }
    
    public static var memorySize: Int {
        return MemoryLayout<GLKVector4>.size + MemoryLayout<GLKVector2>.size
    }
    
    public var primitiveSequence: [GLfloat] {
        var sequence = position.primitiveSequence
        sequence.append(contentsOf: textureCoordinates.primitiveSequence)
        return sequence
    }
    
    let position: GLKVector4
    let textureCoordinates: GLKVector2
    
    init(position: GLKVector4, textureCoordinates: GLKVector2) {
        self.position = position
        self.textureCoordinates = textureCoordinates
    }
}
