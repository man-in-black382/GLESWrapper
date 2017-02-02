//
//  File.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 30.09.16.
//  Copyright © 2016 MPO. All rights reserved.
//

import GLKit

public enum ProgramError: Error {
    case unableToLink(details: String)
    case nonexistentUniform
    case tooManyUniformTextures
}

public class Program: Object, Usable {
    
    // MARK - Properties
    
    private static var availableTextureUnits: [Int32] = {
        var maximumTextureUnits: GLint = 0
        glGetIntegerv(GLenum(GL_MAX_TEXTURE_IMAGE_UNITS), &maximumTextureUnits);
        return [Int32](0..<maximumTextureUnits)
    }()
    
    private var usedTextureUnits = Set<Int32>()
    private var uniforms = [String: Int32]()
    private let vertexShader: Shader
    private let fragmentShader: Shader
    
    // MARK: - Lifecycle
    
    public init(vertexShader: Shader, fragmentShader: Shader) throws {
        let programName = glCreateProgram()

        self.vertexShader = vertexShader
        self.fragmentShader = fragmentShader
        
        glAttachShader(programName, vertexShader.name);
        glAttachShader(programName, fragmentShader.name);
        
        try super.init(name: programName)
        
        try link()
        obtainUniforms()
    }
    
    deinit {
        glDeleteProgram(name)
    }

    // MARK: - Private
    
    private func link() throws {
        glLinkProgram(name);
        
        var linked: GLint = 0;
        glGetProgramiv(name, GLenum(GL_LINK_STATUS), &linked);
        
        if (linked == 0) {
            var infoLength: GLint = 0
            glGetProgramiv(name, GLenum(GL_INFO_LOG_LENGTH), &infoLength);
            
            var errorMessage: String = ""
            
            if infoLength > 1 {
                let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(infoLength))
                glGetProgramInfoLog(name, infoLength, nil, infoLog);
                errorMessage = String(cString: infoLog)
                free(infoLog);
            }
            
            glDeleteProgram(name);
            
            throw ProgramError.unableToLink(details: errorMessage)
        }
    }
    
    private func obtainUniforms()  {
        // Be aware that glGetUniformLocation can still return -1 for an existing,
        // but not used uniform due to GL linker optimizations, which is not an error
        let lines = fragmentShader.source.components(separatedBy: ";")
        let uniformNames = lines.filter{ $0.contains("uniform ") }.map{ $0.components(separatedBy: " ").last! }
        uniforms = uniformNames.reduce([String: Int32](), { [weak self] (namesAndLocations, uniformName) in
            var namesAndLocations = namesAndLocations
            if let programName = self?.name {
                namesAndLocations[uniformName] = glGetUniformLocation(programName, uniformName)
            }
            return namesAndLocations
        })
    }
    
    private func modifyUniform<TextureType: Object where TextureType: Usable>(named name: String, withGeneric texture: TextureType) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        let nonUsedTextureUnits = usedTextureUnits.symmetricDifference(Program.availableTextureUnits)
        guard let textureUnit = nonUsedTextureUnits.first else { throw ProgramError.tooManyUniformTextures }
        usedTextureUnits.insert(textureUnit)

        glActiveTexture(GLenum(GL_TEXTURE0 + textureUnit))
        glUniform1i(uniformLocation, textureUnit);
        texture.use()
    }
    
    // MARK: - Usable protocol
    
    public func use() {
        glUseProgram(name)
    }
    
    // MARK: - Public
    
    public func prepareForRendering() {
        usedTextureUnits.removeAll()
    }
    
    public func modifyUniform(named name: String, with texture: Texture2D) throws {
        try modifyUniform(named: name, withGeneric: texture)
    }
    
    public func modifyUniform(named name: String, with texture: Texture2DArray) throws {
        try modifyUniform(named: name, withGeneric: texture)
    }
    
    public func modifyUniform(named name: String, with value: Int) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        glUniform1i(uniformLocation, GLint(value));
    }
    
    public func modifyUniform(named name: String, with value: Float) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        glUniform1f(uniformLocation, value);
    }
    
    public func modifyUniform(named name: String, with vector: GLKVector2) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        var vector = vector
        glUniform2fv(uniformLocation, 1, vector.primitiveSequence)
    }
    
    public func modifyUniform(named name: String, with vector: GLKVector3) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        var vector = vector
        glUniform3fv(uniformLocation, 1, vector.primitiveSequence)
    }
    
    public func modifyUniform(named name: String, with vector: GLKVector4) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        var vector = vector
        glUniform4fv(uniformLocation, 1, vector.primitiveSequence)
    }
}
