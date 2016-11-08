//
//  VertexAttribute.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 21.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import Foundation
import GLKit

public class Vertex {
    
    // MARK - Properties
    
    internal var attributes: [VertexAttribute]
    internal var decomposedAttributes: [GLfloat]
    internal var memorySize: Int = 0
    
    public init(attributes: [VertexAttribute]) {
        self.attributes = Array(attributes)
        decomposedAttributes = []
        for var attribute in attributes {
            memorySize += attribute.memorySize
            decomposedAttributes.append(contentsOf: UnsafeBufferPointer<GLfloat>(start: attribute.decomposed, count: attribute.numberOfComponents))
        }
    }
    
    internal func replaceAttribute(at location: Int, with attribute: VertexAttribute) {
        var attribute = attribute
        if attributes[location].numberOfComponents != attribute.numberOfComponents {
            // Throw an exception
        }
        attributes[location] = attribute
        let bufferPointer = UnsafeBufferPointer<GLfloat>(start: attribute.decomposed, count: attribute.numberOfComponents)
        decomposedAttributes.replaceSubrange(location..<location + attribute.numberOfComponents, with: bufferPointer)
    }
}

