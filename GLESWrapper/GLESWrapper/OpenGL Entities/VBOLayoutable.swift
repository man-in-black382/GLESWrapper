//
//  VertexAttribute.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 11.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import GLKit

public protocol VBOLayoutable {
    static var memorySize: Int { get }
    var primitiveSequence: [GLfloat] { get }
}

extension Float: VBOLayoutable {
    public static var memorySize: Int {
        return MemoryLayout<Float>.size
    }
    
    public var primitiveSequence: [GLfloat] {
        return [self]
    }
}

extension GLKVector2: VBOLayoutable {
    public static var memorySize: Int {
        return MemoryLayout<GLKVector2>.size
    }
    
    public var primitiveSequence: [GLfloat] {
        return [self.x, self.y]
    }
}

extension GLKVector3: VBOLayoutable {
    public static var memorySize: Int {
        return MemoryLayout<GLKVector3>.size
    }
    
    public var primitiveSequence: [GLfloat] {
        return [self.x, self.y, self.z]
    }
}

extension GLKVector4: VBOLayoutable {
    public static var memorySize: Int {
        return MemoryLayout<GLKVector4>.size
    }
    
    public var primitiveSequence: [GLfloat] {
        return [self.x, self.y, self.z, self.w]
    }
}
