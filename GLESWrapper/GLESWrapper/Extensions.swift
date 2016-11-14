//
//  Extensions.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 25.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import Foundation
import GLKit

extension Float: VertexAttribute {
    public var memorySize: Int {
        return MemoryLayout.size(ofValue: self)
    }

    public var decomposed: UnsafePointer<Float> {
        mutating get {
            return withUnsafePointer(to: &self) {
                return UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self)
            }
        }
    }
    
    public var numberOfComponents: Int {
        return 1
    }
}

extension GLKVector2: VertexAttribute {
    public var memorySize: Int {
        return MemoryLayout.size(ofValue: v)
    }
    
    public var decomposed: UnsafePointer<Float> {
        mutating get {
            return withUnsafePointer(to: &self) {
                return UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self)
            }
        }
    }
    
    public var numberOfComponents: Int {
        return 2
    }
}

extension GLKVector3: VertexAttribute {
    public var memorySize: Int {
        return MemoryLayout.size(ofValue: v)
    }
    
    public var decomposed: UnsafePointer<Float> {
        mutating get {
            return withUnsafePointer(to: &self) {
                return UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self)
            }
        }
    }
    
    public var numberOfComponents: Int {
        return 3
    }
}

extension GLKVector4: VertexAttribute {
    public var memorySize: Int {
        return MemoryLayout.size(ofValue: v)
    }
    
    public var decomposed: UnsafePointer<Float> {
        mutating get {
            return withUnsafePointer(to: &self) {
                return UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self)
            }
        }
    }
    
    public var numberOfComponents: Int {
        return 4
    }
}

extension UIView: Sizeable {
    var size: CGSize {
        return bounds.size
    }
}

extension GLKView: Usable {
    func use() {
        bindDrawable()
    }
}
