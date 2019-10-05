//
//  FAIcon.swift
//  link-swiftui
//
//  Created by Matt Maddux on 10/1/19.
//  Copyright © 2019 Matt Maddux. All rights reserved.
//

import SwiftUI

// ======================================================= //
// MARK: - Style Enum
// ======================================================= //

public enum FAStyle: String, Codable {
    case light
    case regular
    case solid
    case brands
    case duotone
    
    var weight: Font.Weight {
        switch self {
        case .light:
            return .light
        case .solid:
            return .heavy
        default:
            return .regular
        }
    }
}

// ======================================================= //
// MARK: - Collection Enum
// ======================================================= //

enum FACollection: String {
    case pro = "Font Awesome 5 Pro"
    case free = "Font Awesome 5 Free"
    case brands = "Font Awesome 5 Brands"
}

// ======================================================= //
// MARK: - Icon Struct
// ======================================================= //

public struct FAIcon: Identifiable, Decodable, Comparable {
    
    // ======================================================= //
    // MARK: - Properties
    // ======================================================= //
    
    public var id: String?
    public var label: String
    public var unicode: String
    public var styles: [FAStyle]
    public var searchTerms: [String]
    
    
    var collection: FACollection {
        if styles.contains(.brands) {
            return .brands
        } else if UIFont.familyNames.contains(FACollection.pro.rawValue){
            return .pro
        } else {
            return .free
        }
    }
    
    var unicodeString: String {
        let rawMutable = NSMutableString(string: "\\u\(self.unicode)")
        CFStringTransform(rawMutable, nil, "Any-Hex/Java" as NSString, true)
        return rawMutable as String
    }
    
    // ======================================================= //
    // MARK: - Initializer
    // ======================================================= //
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = try values.decode(String.self, forKey: .label)
        unicode = try values.decode(String.self, forKey: .unicode)
        styles = try values.decode([FAStyle].self, forKey: .styles)
        
        let search = try values.nestedContainer(keyedBy: SearchKeys.self, forKey: .search)
        let rawSearchTerms = try search.decode([RawSearchTerm].self, forKey: .terms)
        searchTerms = [String]()
        for term in rawSearchTerms {
            searchTerms.append(term.toString())
        }
    }
    
    // ======================================================= //
    // MARK: - Coding Keys
    // ======================================================= //
    
    public enum CodingKeys: String, CodingKey {
        case label
        case unicode
        case styles
        case search
    }
    
    public enum SearchKeys: String, CodingKey {
        case terms
    }
    
    // ======================================================= //
    // MARK: - Decoding Helper Types
    // ======================================================= //
    
    enum RawSearchTerm: Decodable {
        case int(Int)
        case string(String)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .int(container.decode(Int.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try .string(container.decode(String.self))
                } catch DecodingError.typeMismatch {
                    throw DecodingError.typeMismatch(RawSearchTerm.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload conflicts with expected type, (Int or String)"))
                }
            }
        }
        
        func toString() -> String {
            switch self {
            case .int(let storedInt):
                return String(storedInt)
            case .string(let storedString):
                return storedString
            }
        }
    }
    
    // ======================================================= //
    // MARK: - Comparable
    // ======================================================= //
    
    public static func < (lhs: FAIcon, rhs: FAIcon) -> Bool {
        return lhs.id ?? lhs.label < lhs.id ?? rhs.label
    }
    
    public static func == (lhs: FAIcon, rhs: FAIcon) -> Bool {
        return lhs.id ?? lhs.label == lhs.id ?? rhs.label
    }
}
