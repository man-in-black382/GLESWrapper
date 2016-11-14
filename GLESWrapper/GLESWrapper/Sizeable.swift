//
//  Sizeable.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 11.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum SizeError: Error {
    case invalidSize(details: String)
}

internal protocol Sizeable {
    var size: CGSize { get }
    func validate(size: CGSize) throws
}

internal extension Sizeable {
    func validate(size: CGSize) throws {
        if size.width == 0 || size.height == 0 {
            throw SizeError.invalidSize(details: "Size cannot have dimensions of 0")
        }
    }
}
