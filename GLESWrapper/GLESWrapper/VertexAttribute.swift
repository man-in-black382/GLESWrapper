//
//  VertexAttribute.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 11.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public protocol VertexAttribute {
    var numberOfComponents: Int { get }
    var decomposed: UnsafePointer<Float> { mutating get }
    var memorySize: Int { get }
}
