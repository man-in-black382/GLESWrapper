//
//  WavefrontMaterialLoader.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 01.02.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import GLKit
import UIKit

fileprivate enum SourceDataMarker: NSString {
    case materialName = "newmtl"
    case ambientColor = "Ka"
    case diffuseColor = "Kd"
    case specularColor = "Ks"
    case opticalDensity = "Ni" // a.k.a index of refraction
    case specularExponent = "Ns"
    case transmissionFilter = "Tf"
    case transparency = "Tr"
    case illuminationModel = "illum"
    case dissolve = "d"
    case ambientMap = "map_Ka"
    case diffuseMap = "map_Kd"
    case specularMap = "map_Ks"
    case specularExponentMap = "map_Ns" // a.k.a specular highlight map
    case alphaMap = "map_d"
    case bumpMap = "bump"
    case displacementMap = "disp"
    case stencilDecal = "decal"
}

internal class WavefrontMaterialLoader: WavefrontLoader {
    
    private let material: WavefrontMaterial
    
    init?(name: String, bundle: Bundle) throws {
        guard let path = bundle.path(forResource: name, ofType: "mtl") else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        let content = try String(contentsOf: url)
        
        material = WavefrontMaterial()
        
        super.init(scanner: Scanner(string: content))
    }
    
    internal func loadMaterial() throws -> WavefrontMaterial {
        while !scanner.isAtEnd {
            switch try readMarker() {
            case .materialName:
                material.name = try readToken(errorMessage: "Unable to read material name") as String!
            case .ambientColor:
                material.ambientColor = try readColor()
            case .diffuseColor:
                material.diffuseColor = try readColor()
            case .specularColor:
                material.specularColor = try readColor()
            case .opticalDensity: break
            case .specularExponent: break
            case .illuminationModel:
                material.illuminationModel = try readIlluminationModel()
            case .dissolve:
                material.dissolve = try readFloat(errorMessage: "Unable to read dissolve component")
//            case .ambientMap = "map_Ka"
//            case .diffuseMap = "map_Kd"
//            case .specularMap = "map_Ks"
//            case .specularExponentMap = "map_Ns" // a.k.a specular highlight map
//            case .alphaMap = "map_d"
//            case .bumpMap = "bump"
//            case .displacementMap = "disp"
//            case .stencilDecal = "decal"
            }
            
            moveToNextLine()
        }
    }

    private func readMarker() throws -> SourceDataMarker {
        let markerString = try readToken(errorMessage: "Unable to deternime a marker")
        guard let sourceDataMarker = SourceDataMarker(rawValue: markerString) else {
            throw ModelLoadingError.invalidData(details: "Marker \(markerString) is unacceptable")
        }
        return sourceDataMarker
        GLKTextureInfo
    }
    
    private func readColor() throws -> GLKVector3 {
        let r = try readFloat(errorMessage: "Missing color R component")
        let g = try readFloat(errorMessage: "Missing color G component")
        let b = try readFloat(errorMessage: "Missing color B component")

        if r < 0.0 || r > 1.0 {
            throw ModelLoadingError.invalidData(details: "Color r value \(r) is not in the 0.0 <= r <= 1.0 range")
        }
        
        if g < 0.0 || g > 1.0 {
            throw ModelLoadingError.invalidData(details: "Color g value \(g) is not in the 0.0 <= g <= 1.0 range")
        }
        
        if b < 0.0 || b > 1.0 {
            throw ModelLoadingError.invalidData(details: "Color b value \(b) is not in the 0.0 <= b <= 1.0 range")
        }
        
        return GLKVector3(v: (r, g, b))
    }
    
    private func readIlluminationModel() throws -> WavefrontIlluminationModel {
        let modelNumber = try readInt(errorMessage: "Cannot read illumination model")
        guard let model = WavefrontIlluminationModel(rawValue: modelNumber) else {
            throw ModelLoadingError.invalidData(details: "Invalid illumination model (\(modelNumber))")
        }
        return model
    }
}
