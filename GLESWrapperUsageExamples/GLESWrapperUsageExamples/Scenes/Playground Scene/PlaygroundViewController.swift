//
//  PlaygroundViewController.swift
//  GLESWrapperUsageExamples
//
//  Created by Pavlo Muratov on 25.01.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import GLKit
import GLESWrapper

// MARK: - Lifecycle
extension PlaygroundViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContext()
        setupRenderPipelineObjects()
    }
}

class PlaygroundViewController: GLKViewController {

    let context = EAGLContext(api: .openGLES3)
    var vertexArray: VertexArray<WavefrontVertex>!
    var renderer: Renderer<WavefrontVertex>!
    
    // MARK: - Setup
    
    func setupContext() {
        let glkView = view as! GLKView
        glkView.context = context!
        glkView.drawableDepthFormat = .format24
        EAGLContext.setCurrent(context)
    }
    
    func setupRenderPipelineObjects() {
        let loader = try! WavefrontModelLoader(modelName: "spot")
        let model = try! loader.loadModel()
        
        vertexArray = try! VertexArray(vertices: model.vertices, indices: model.indices)
        
        let program = try! Program(vertexShader: Shader(resourceName: "BlinnPhong.vsh", type: .vertex),
                                   fragmentShader: Shader(resourceName: "BlinnPhong.fsh", type: .fragment))
        
        renderer = Renderer(program: program, vertexArray: vertexArray, drawPattern: .triangles)
    }
    
    // MARK: - Rendering
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        renderer.render(to: view) { (configuration) in
            configuration.viewport = CGRect(x: 0.0, y: 0.0, width: 400, height: 400)
        }
    }
}
