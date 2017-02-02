//
//  VertexAttribute.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 21.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import GLKit

public class VertexAttributeLayout {
    var location: Int
    var memorySize: Int
    
    public init(location: Int, memorySize: Int) {
        self.location = location
        self.memorySize = memorySize
    }
}

public protocol Vertex: VBOLayoutable {
    static var attributeLayouts: [VertexAttributeLayout] { get }
}

