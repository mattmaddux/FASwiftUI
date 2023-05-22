//
//  FontAwesome.swift
//  link-swiftui
//
//  Created by Matt Maddux on 9/23/19.
//  Copyright © 2019 Matt Maddux. All rights reserved.
//

import SwiftUI

public class FontAwesome {
    
    // ======================================================= //
    // MARK: - Shared Instance
    // ======================================================= //
    
    public static var shared: FontAwesome = FontAwesome()
    
    // ======================================================= //
    // MARK: - Published Properties
    // ======================================================= //
    
    public private(set) var store: [String: FAIcon]
    
    // ======================================================= //
    // MARK: - Initializer
    // ======================================================= //
    
    init() {
        let fileURL = Bundle.main.url(forResource: "icons", withExtension: "json")!
        let jsonString = try! String(contentsOf: fileURL, encoding: .utf8)
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        self.store = try! decoder.decode([String: FAIcon].self, from: jsonData)
        for key in store.keys {
            store[key]!.id = key
        }
    }
    
    
    // ======================================================= //
    // MARK: - Methods
    // ======================================================= //
    
    public func icon(byName name: String) -> FAIcon? {
        return store[name.lowercased()]
    }
    
    // icon(byAlias:) added to allow FA5 backwards compatibility where names have changed and moved to an aliases array
    public func icon(byAlias name: String) -> FAIcon? {
        var iconName = ""
        for item in store {
            if let aliasNames = item.value.aliasNames, aliasNames.contains(name) {
                iconName = item.value.id ?? name
                print("found \(name) by alias as \(iconName)")
                return store[iconName.lowercased()]
            }
        }
        return store[iconName.lowercased()]
    }
    
    public func search(query: String) -> [String: FAIcon] {
        let filtered = store.filter() {
            if $0.key.contains(query) {
                return true
            } else {
                for term in $0.value.searchTerms {
                    if term.contains(query) {
                        return true
                    }
                }
                return false
            }
        }
        return filtered
    }

}
