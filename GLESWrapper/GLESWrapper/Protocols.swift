//
//  Protocols.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 27.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import UIKit

public protocol Usable {
    func use()
}

public protocol Sizeable {
    var size: CGSize { get }
}

public protocol VertexAttribute {
    var numberOfComponents: Int { get }
    var decomposed: UnsafePointer<Float> { mutating get }
    var memorySize: Int { get }
}
