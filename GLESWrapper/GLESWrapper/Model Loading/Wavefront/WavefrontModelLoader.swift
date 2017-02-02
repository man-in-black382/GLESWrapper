//
//  ModelLoader.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 25.01.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import GLKit

fileprivate enum SourceDataMarker: NSString {
    case comment = "#"
    case vertex = "v"
    case normal = "vn"
    case textureCoordinates = "vt"
    case object = "o"
    case group = "g"
    case face = "f"
    case smoothShading = "s"
    case materialLibrary = "mtllib"
    case materialName = "usemtl"
}

fileprivate class VertexAttributesIndexSet {
    var positionIndex: Int = 0
    var textureCoordinateIndex: Int?
    var normalIndex: Int?
}

fileprivate class Face {
    let indexSets: [VertexAttributesIndexSet] = [VertexAttributesIndexSet(), VertexAttributesIndexSet(), VertexAttributesIndexSet()]
}

fileprivate class TemporaryVertexAttributesContainer {
    var positions = [GLKVector4]()
    var textureCoordinates = [GLKVector3]()
    var normals = [GLKVector3]()
}

public class WavefrontModelLoader: WavefrontLoader {
    
    private var model: WavefrontModel = WavefrontModel()
    private var temporaryContainer: TemporaryVertexAttributesContainer = TemporaryVertexAttributesContainer()
    
    public init(modelName: String, bundle: Bundle = Bundle.main) throws {
        guard let path = bundle.path(forResource: modelName, ofType: "obj") else {
            throw ModelLoadingError.fileNotFound
        }
        let url = URL(fileURLWithPath: path)
        let content = try String(contentsOf: url)
        
        super.init(scanner: Scanner(string: content))
    }
    
    public func loadModel() throws -> WavefrontModel {
        while !scanner.isAtEnd {
            switch try readMarker() {
            case .vertex:
                let position = try readVertexPosition()
                model.vertices.append(WavefrontVertex(position: position))
                temporaryContainer.positions.append(position)
                
            case .textureCoordinates:
                temporaryContainer.textureCoordinates.append(try readTextureCoordinates())
    
            case .normal:
                temporaryContainer.normals.append(try readNormal())
                
            case .face:
                let face = try readFace()
                for indexSet in face.indexSets {
                    let normalizedPositionIndex = normalizeIndex(index: indexSet.positionIndex, totalAmount: temporaryContainer.positions.count)
                    model.vertices[normalizedPositionIndex].position = temporaryContainer.positions[normalizedPositionIndex]
                    
                    // Texture coordinates are optional
                    if let index = indexSet.textureCoordinateIndex {
                        let normalizedTextureCoodinatesIndex = normalizeIndex(index: index, totalAmount: temporaryContainer.textureCoordinates.count)
                        model.vertices[normalizedPositionIndex].textureCoordinates = temporaryContainer.textureCoordinates[normalizedTextureCoodinatesIndex]
                    }
                    
                    // As well as normals
                    if let index = indexSet.normalIndex {
                        let normalizedNormalIndex = normalizeIndex(index: index, totalAmount: temporaryContainer.normals.count)
                        model.vertices[normalizedPositionIndex].normal = temporaryContainer.normals[normalizedNormalIndex]
                    }
                    
                    model.indices.append(GLushort(normalizedPositionIndex))
                }
                
            case .object: print("object")
            case .group: print("group")
            case .materialLibrary: print("materialLibrary")
            case .materialName: print("materialName")
            case .smoothShading: print("smoothShading")
            case .comment: break
            }
            
            moveToNextLine()
        }
                
        return model
    }
    
    private func readMarker() throws -> SourceDataMarker {
        let markerString = try readToken(errorMessage: "Unable to deternime a marker")
        guard let sourceDataMarker = SourceDataMarker(rawValue: markerString) else {
            throw ModelLoadingError.invalidData(details: "Marker \(markerString) is unacceptable")
        }
        return sourceDataMarker
    }
    
    private func readVertexPosition() throws -> GLKVector4 {
        let x = try readFloat(errorMessage: "Cannot read vertex X value")
        let y = try readFloat(errorMessage: "Cannot read vertex Y value")
        let z = try readFloat(errorMessage: "Cannot read vertex Z value")
        
        var w: Float = 1.0
        scanner.scanFloat(&w)
        
        return GLKVector4(v: (x, y, z, w))
    }

    private func readTextureCoordinates() throws -> GLKVector3  {
        let u = try readFloat(errorMessage: "Cannot read texture U coordinate")
        let v = try readFloat(errorMessage: "Cannot read texture V coordinate")
        
        var w: Float = 0.0
        scanner.scanFloat(&w)
        
        return GLKVector3(v: (u, v, w))
    }
    
    private func readNormal() throws -> GLKVector3  {
        let x = try readFloat(errorMessage: "Cannot read normal X value")
        let y = try readFloat(errorMessage: "Cannot read normal Y value")
        let z = try readFloat(errorMessage: "Cannot read normal Z value")

        return GLKVector3(v: (x, y, z))
    }

    private func readFace() throws -> Face {
        let face = Face()

        for indexSet in face.indexSets {
            var index: Int = 0
            
            guard scanner.scanInt(&index) else {
                throw ModelLoadingError.unreadableData(details: "Cannot read texture coodinates index")
            }
            
            indexSet.positionIndex = index
            
            guard scanner.scanString("/", into: nil) else {
                throw ModelLoadingError.invalidData(details: "Missing '/' in face definition")
            }
        
            if scanner.scanInt(&index) {
                indexSet.textureCoordinateIndex = index
            }
            
            guard scanner.scanString("/", into: nil) else {
                throw ModelLoadingError.invalidData(details: "Missing '/' in face definition")
            }
            
            if scanner.scanInt(&index) {
                indexSet.normalIndex = index
            }
        }

        return face
    }
    
    private func normalizeIndex(index: Int, totalAmount: Int) -> Int {
        if index == 0 {
            return index
        }
        
        if index > 0 {
            return index - 1
        }
        
        return index - totalAmount - 1
    }
}
