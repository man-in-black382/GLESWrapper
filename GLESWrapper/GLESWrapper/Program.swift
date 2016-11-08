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
}

public class Program: Object, Usable {
    
    // MARK - Properties
    
    private var uniforms: [String: Int32] = [:]
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
    
    // MARK: - Usable protocol
    
    public func use() {
        glUseProgram(name)
    }
    
    // MARK: - Public
    
    public func modifyUniform(named name: String, with texture: Texture2D) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        glUniform1i(uniformLocation, GLint(texture.name));
    }
    
    public func modifyUniform(named name: String, with value: Float) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        glUniform1f(uniformLocation, value);
    }
    
    public func modifyUniform(named name: String, with vector: GLKVector2) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        var vector = vector
        let pointer = withUnsafePointer(to: &vector, { UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self) })
        glUniform2fv(uniformLocation, 2, pointer)
    }
    
    public func modifyUniform(named name: String, with vector: GLKVector3) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        var vector = vector
        let pointer = withUnsafePointer(to: &vector, { UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self) })
        glUniform3fv(uniformLocation, 3, pointer)
    }
    
    public func modifyUniform(named name: String, with vector: GLKVector4) throws {
        guard let uniformLocation = uniforms[name] else { throw ProgramError.nonexistentUniform }
        var vector = vector
        let pointer = withUnsafePointer(to: &vector, { UnsafeRawPointer($0).assumingMemoryBound(to: GLfloat.self) })
        glUniform4fv(uniformLocation, 4, pointer)
    }
}
