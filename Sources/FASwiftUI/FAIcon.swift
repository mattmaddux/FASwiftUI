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
    case sharp
    case duotone
    // FA6 added thin style
    case thin

    var weight: Font.Weight {
        switch self {
        case .light:
            return .light
        case .solid:
            return .heavy
            // FA6 added thin style
        case .thin:
            return .thin
        default:
            return .regular
        }
    }
}

// ======================================================= //
// MARK: - Collection Enum
// ======================================================= //

enum FACollection: String {
    case pro = "Font Awesome 6 Pro"
    case free = "Font Awesome 6 Free"
    case brands = "Font Awesome 6 Brands"
    case sharp = "Font Awesome 6 Sharp"
    // FA5 backwards compatibility
    case pro5 = "Font Awesome 5 Pro"
    case free5 = "Font Awesome 5 Free"
    case brands5 = "Font Awesome 5 Brands"

    static var availableCollection: [FACollection] {
        var result = [FACollection]()
        if FACollection.isAvailable(collection: .pro) || FACollection.isAvailable(collection: .pro5) {
            result.append(.pro)
        }
        if FACollection.isAvailable(collection: .free) || FACollection.isAvailable(collection: .free5) {
            result.append(.free)
        }
        if FACollection.isAvailable(collection: .brands) || FACollection.isAvailable(collection: .brands5) {
            result.append(.brands)
        }
        if FACollection.isAvailable(collection: .sharp) {
            result.append(.sharp)
        }
        return result
    }

    static func isAvailable(collection: FACollection) -> Bool {
        #if os(iOS)
            return UIFont.familyNames.contains(collection.rawValue)
        #elseif os(OSX)
            return NSFontManager.shared.availableFontFamilies.contains(collection.rawValue)
        #endif
    }
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
    // FA6 changed many names. Old names stored in aliases array
    public var aliasNames: [String]? = []

    var collection: FACollection {
        if styles.contains(.brands) {
            return .brands
        } else if styles.contains(.sharp) {
            return .sharp
        } else if FACollection.isAvailable(collection: .pro) {
            return .pro
        } else {
            return .free
        }
    }

    // many FA6 unicodes do not provide 4 characters so adding leading zeros
    var paddedCode: String {
        var code = self.unicode
        while code.count < 4 {
            code = "0" + code
        }
        return code
    }

    var unicodeString: String {
        let rawMutable = NSMutableString(string: "\\u\(paddedCode)")
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
        // FA6 changed many names. Old names stored in aliases array
        let aliases = try? values.nestedContainer(keyedBy: AliasKeys.self, forKey: .aliases)
        let rawAliases = try? aliases?.decode([RawAlias].self, forKey: .names)
        aliasNames = [String]()
        for name in rawAliases ?? [] {
            if aliasNames?.append(name.toString()) == nil {
                aliasNames = [name.toString()]
            }
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
        // FA6 changed many names. Old names stored in aliases array
        case aliases
    }

    public enum SearchKeys: String, CodingKey {
        case terms
    }
    // FA6 changed many icon names and moved the old ones to an aliases array.
    public enum AliasKeys: String, CodingKey {
        case names
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

    // FA6 changed many icon names and moved the old ones to an aliases array. Decoder modified accordingly
    enum RawAlias: Decodable {
        case int(Int)
        case string(String)

        init(from decoder: Decoder) throws {
            let container = try? decoder.singleValueContainer()
            do {
                self = try .int(container?.decode(Int.self) ?? 0)
            } catch DecodingError.typeMismatch {
                do {
                    self = try .string(container?.decode(String.self) ?? "")
                } catch DecodingError.typeMismatch {
                    throw DecodingError.typeMismatch(RawAlias.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload conflicts with expected type, (Int or String)"))
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
