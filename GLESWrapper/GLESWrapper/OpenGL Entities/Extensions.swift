//
//  Extensions.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 25.10.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import GLKit

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
