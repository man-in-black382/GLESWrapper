//
//  2DLightingViewController.swift
//  GLESWrapperUsageExamples
//
//  Created by Pavlo Muratov on 08.11.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import UIKit
import GLESWrapper
import GLKit

// MARK: - Lifecycle
extension LightingViewController {
    override func viewDidLoad() {
        setupContext()
        setupRenderer()
    }
}

class LightingViewController: GLKViewController {
    // MARK - Properties
    
    let context = EAGLContext(api: .openGLES3)
    var renderer: Renderer<Vertex>!
    var gradientFramebuffer: Framebuffer!
    var sampleFramebuffer: Framebuffer!
    
    func setupContext() {
        let glkView = view as! GLKView
        glkView.context = context!
        glkView.drawableDepthFormat = .format24
        EAGLContext.setCurrent(context)
    }
    
    func setupRenderer() {
        let program = try! Program(vertexShader: Shader(resourceName: "VertexShader.vsh", type: .vertex),
                                   fragmentShader: Shader(resourceName: "FragmentShader.fsh", type: .fragment))
        
        let bottomLeftCorner = Vertex(attributes: [GLKVector4(v: (-0.8, -0.8, 0, 1)), GLKVector4(v: (1, 0, 0, 1))])
        let topLeftCorner = Vertex(attributes: [GLKVector4(v: (-0.9, 0.9, 0, 1)), GLKVector4(v: (0, 1, 0, 1))])
        let bottomRightCorner = Vertex(attributes: [GLKVector4(v: (0.8, -0.8, 0, 1)), GLKVector4(v: (0, 0, 1, 1))])
        let topRightCorner = Vertex(attributes: [GLKVector4(v: (0.9, 0.9, 0, 1)), GLKVector4(v: (1, 1, 1, 1))])
        
        let vertexArray = try! VertexArray(vertices: [bottomLeftCorner, topLeftCorner, bottomRightCorner, topRightCorner], indices: [0, 1, 2, 3])
        renderer = Renderer(program: program, vertexArray: vertexArray, drawPattern: .triangleStrip)
        
        gradientFramebuffer = try! Framebuffer()
        gradientFramebuffer.attach(texture: try! Texture2D(size: view.bounds.size), to: .attachment0)
        
        sampleFramebuffer = try! Framebuffer()
        sampleFramebuffer.attach(texture: try! Texture2D(size: CGSize(width: 100, height: 100)), to: .attachment0)
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        renderer.renderOffscreen(configuration: nil, framebuffer: gradientFramebuffer)
        try! Framebuffer.copy(from: gradientFramebuffer, attachment: .attachment0, rectangle: CGRect(x: -30, y: -30, width: 70, height: 70),
                              to: sampleFramebuffer, attachment: .attachment0, rectangle: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
}
