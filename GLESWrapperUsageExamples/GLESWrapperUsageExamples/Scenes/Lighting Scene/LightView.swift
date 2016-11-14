//
//  LightView.swift
//  GLESWrapperUsageExamples
//
//  Created by Pavlo Muratov on 09.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import UIKit
import GLKit

class LightView: UIImageView {

    // MARK: - Properties
    
    @IBInspectable var lightColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        willSet {
            tintColor = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(recognized(pan:)))
        addGestureRecognizer(panRecognizer)
        isUserInteractionEnabled = true
    }
    
    func recognized(pan: UIPanGestureRecognizer) {
        center = pan.location(in: superview)
    }
}

extension LightView {
    var glLightColor: GLKVector4 {
        let ciColor = CIColor(color: lightColor)
        return GLKVector4(v: (Float(ciColor.red), Float(ciColor.green), Float(ciColor.blue), Float(ciColor.alpha)))
    }
}
