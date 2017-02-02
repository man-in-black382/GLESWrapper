//
//  ModelLoadingError.swift
//  GLESWrapper
//
//  Created by Pavlo Muratov on 01.02.17.
//  Copyright © 2017 MPO. All rights reserved.
//

import Foundation

public enum ModelLoadingError: Error {
    case fileNotFound
    case unreadableData(details: String)
    case invalidData(details: String)
}

public class WavefrontLoader {
    
    internal let scanner: Scanner
    
    internal init(scanner: Scanner) {
        self.scanner = scanner
        self.scanner.charactersToBeSkipped = CharacterSet.whitespaces
    }
    
    internal func moveToNextLine() {
        scanner.scanUpToCharacters(from: CharacterSet.newlines, into: nil)
        scanner.scanCharacters(from: CharacterSet.whitespacesAndNewlines, into: nil)
    }
    
    internal func readToken(errorMessage: String) throws -> NSString {
        var token: NSString?
        guard scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &token) else {
            throw ModelLoadingError.unreadableData(details: errorMessage)
        }
        return token!
    }
    
    internal func readInt(errorMessage: String) throws -> Int {
        var number: Int = 0
        guard scanner.scanInt(&number) else {
            throw ModelLoadingError.unreadableData(details: errorMessage)
        }
        return number
    }
    
    internal func readFloat(errorMessage: String) throws -> Float {
        var number: Float = 0.0
        guard scanner.scanFloat(&number) else {
            throw ModelLoadingError.unreadableData(details: errorMessage)
        }
        return number
    }
}
