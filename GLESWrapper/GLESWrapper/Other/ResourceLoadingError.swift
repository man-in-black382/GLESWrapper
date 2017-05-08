//
//  ResourceLoadingError.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 03.02.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import Foundation

public enum ResourceLoadingError: Error {
    case fileNotFound(fileName: String)
}
