//
//  Model.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 25.01.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import Foundation

public class WavefrontModel {
    public var vertices = [WavefrontVertex]()
    public var indices = [GLushort]()
    internal var material: WavefrontMaterial?
}
