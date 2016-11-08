//
//  Shader.swift
//  OpenGLWrapper
//
//  Created by Pavlo Muratov on 30.09.16.
//  Copyright © 2016 MPO. All rights reserved.
//

public enum ShaderType {
    case vertex
    case fragment
    
    internal var glType: GLenum {
        switch self {
        case .vertex: return GLenum(GL_VERTEX_SHADER)
        case .fragment: return GLenum(GL_FRAGMENT_SHADER)
        }
    }
}

public enum ShaderError: Error {
    case failedCompilation(details: String)
    case sourceFileNotFound
}

public class Shader: Object {
    
    // MARK - Properties
    
    internal let type: ShaderType
    internal let source: String
    
    // MARK: - Lifecycle
    
    public init(resourceName: String, type: ShaderType) throws {
        guard let shaderSourcePath = Bundle.main.path(forResource: resourceName, ofType: nil) else {
            throw ShaderError.sourceFileNotFound
        }
        
        let source = try String(contentsOfFile: shaderSourcePath)
        let name = glCreateShader(type.glType)
        var cSource = (source as NSString).utf8String
        
        glShaderSource(name, 1, &cSource, nil)
        glCompileShader(name);
        
        var compiled: GLint = 0
        glGetShaderiv(name, GLenum(GL_COMPILE_STATUS), &compiled)
        
        if compiled == 0 {
            
            var infoLength: GLint = 0
            glGetShaderiv(name, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            var errorMessage: String = ""
            
            if infoLength > 1 {
                let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(infoLength))
                glGetShaderInfoLog(name, infoLength, nil, infoLog)
                errorMessage = String(cString: infoLog)
                free(infoLog);
            }
            
            glDeleteShader(name);
            
            throw ShaderError.failedCompilation(details: errorMessage)
        }
        
        self.type = type
        self.source = source
        
        try super.init(name: name)
    }
    
    deinit {
        glDeleteShader(name)
    }
}
