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
        setupRenderPipelineObjects()
        
        for obstacle in obstacles {
            obstacle.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
}

class LightingViewController: GLKViewController {
    
    // MARK: - Properties
    
    // MARK - Scene settings
    @IBInspectable var lightRadius: Int = 0
    @IBInspectable var lightRaysCount: Int = 0
    
    // MARK - Outlets
    @IBOutlet var lights: [LightView]!
    @IBOutlet var obstacles: [UIImageView]!
    @IBOutlet weak var occludersContainerView: UIView!
    @IBOutlet weak var testLabel: UILabel!
    
    // MARK - Render pipeline stuff
    let context = EAGLContext(api: .openGLES3)
    
    var shadowMapRenderer: Renderer<Vertex>!
    var lightsRenderer: Renderer<Vertex>!
    
    var occludersTexture: Texture2D!
    var occludersFramebuffer: Framebuffer!
    
    var occluderSamplesTextureArray: Texture2DArray!
    var occluderSamplesFramebuffer: Framebuffer!
    
    var shadowMapFramebuffer: Framebuffer!
    var shadowMapTexture: Texture2D!
    
    // MARK: - Setup
    
    func setupContext() {
        let glkView = view as! GLKView
        glkView.context = context!
        glkView.drawableDepthFormat = .format24
        EAGLContext.setCurrent(context)
    }
    
    func setupRenderPipelineObjects() {
        
        let bottomLeftCorner = Vertex(attributes:
            [GLKVector4(v: (-1, -1, 0, 1)), // Vertex coordinate
            GLKVector2(v: (0, 0))]) // Occluders sample texture (specific for corresponding light) coordinates
        let topLeftCorner = Vertex(attributes: [GLKVector4(v: (-1, 1, 0, 1)), GLKVector2(v: (0, 1))])
        let bottomRightCorner = Vertex(attributes: [GLKVector4(v: (1, -1, 0, 1)), GLKVector2(v: (1, 0))])
        let topRightCorner = Vertex(attributes: [GLKVector4(v: (1, 1, 0, 1)), GLKVector2(v: (1, 1))])
        
        let vertexArray = try! VertexArray(vertices: [bottomLeftCorner, topLeftCorner, bottomRightCorner, topRightCorner], indices: [0, 1, 2, 3])
        
        let shadowMapRenderingProgram = try! Program(vertexShader: Shader(resourceName: "ShadowMapRenderer.vsh", type: .vertex),
                                                     fragmentShader: Shader(resourceName: "ShadowMapRenderer.fsh", type: .fragment))
        
        let lightsRenderingProgram = try! Program(vertexShader: Shader(resourceName: "LightRenderer.vsh", type: .vertex),
                                                     fragmentShader: Shader(resourceName: "LightRenderer.fsh", type: .fragment))
        
        shadowMapRenderer = Renderer(program: shadowMapRenderingProgram, vertexArray: vertexArray, drawPattern: .triangleStrip)
        lightsRenderer = Renderer(program: lightsRenderingProgram, vertexArray: vertexArray, drawPattern: .triangleStrip)
        
        // Texture will contain contents of the occludersContainerView
        occludersTexture = try! Texture2D(size: occludersContainerView.bounds.size)
        try! occludersTexture.update(withContentsOf: occludersContainerView)
        
        //
        occludersFramebuffer = try! Framebuffer(size: occludersTexture.size)
        try! occludersFramebuffer.attach(texture: occludersTexture, to: .attachment0)
        
        //
        shadowMapTexture = try! Texture2D(sizeInPixels: CGSize(width: lightRaysCount, height: lights.count))
        shadowMapFramebuffer = try! Framebuffer(size: shadowMapTexture.size)
        try! shadowMapFramebuffer.attach(texture: shadowMapTexture, to: .attachment0)
        
        //
        let lightDiameter = Int(lightRadius * 2)
        occluderSamplesTextureArray = try! Texture2DArray(size: CGSize(width: lightDiameter, height: lightDiameter), capacity: UInt(lights.count))
        occluderSamplesFramebuffer = try! Framebuffer(size: occluderSamplesTextureArray.size)
    }
    
    // MARK: - Utility methods
    
    func lightFrame(for light: LightView) -> CGRect {
        return CGRect(x: light.center.x - CGFloat(lightRadius), y: light.center.y - CGFloat(lightRadius),
                      width: CGFloat(lightRadius * 2), height: CGFloat(lightRadius * 2))
    }
    
    // MARK: - Rendering
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        for (index, light) in lights.enumerated() {
            let frame = lightFrame(for: light)
            var bounds = frame
            bounds.origin = .zero
            try! occluderSamplesFramebuffer.attach(layer: index, of: occluderSamplesTextureArray, to: .attachment0)
            try! Framebuffer.copy(from: occludersFramebuffer, attachment: .attachment0, rectangle: frame,
                                  to: occluderSamplesFramebuffer, attachment: .attachment0, rectangle: bounds)
        }
        
        shadowMapRenderer.render(to: shadowMapFramebuffer, configuration: { [weak self] (configuration) in
            configuration.buffersToClear = [.color]
            try! configuration.program.modifyUniform(named: "u_occlusionMapsCount", with: Float(self!.lights.count))
            try! configuration.program.modifyUniform(named: "u_shadowMapSize", with: Float(self!.lightRaysCount))
            try! configuration.program.modifyUniform(named: "u_occlusionMaps", with: self!.occluderSamplesTextureArray)
        })
        
        lightsRenderer.render(to: view, numberOfPasses: lights.count, configuration: { (configuration) in
            configuration.buffersToClear = [.color]
            glEnable(GLenum(GL_BLEND));
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE));
        }, singlePassConfiguration: { [weak self] (pass, configuration) in
            let light = self!.lights[pass]
            configuration.viewport = self!.lightFrame(for: light)
            try! configuration.program.modifyUniform(named: "u_shadowMapTexture", with: self!.shadowMapTexture)
            try! configuration.program.modifyUniform(named: "u_shadowMapSize", with: GLKVector2(v: (Float(self!.lightRaysCount), Float(self!.lights.count))))
            try! configuration.program.modifyUniform(named: "u_lightIndex", with: Float(pass))
            try! configuration.program.modifyUniform(named: "u_lightColor", with: light.glLightColor)
        })
    }
}
