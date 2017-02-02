//
//  Object.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 30.09.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum GLObjectError: Error {
    case unableToCreate(suggestion: String)
}

public class Object {
    var name: GLuint
    
    init(name: GLuint) throws {
        if name == 0 {
            throw GLObjectError.unableToCreate(suggestion: "Make sure your GL context has been successfully set up")
        }
        self.name = name
    }
}
