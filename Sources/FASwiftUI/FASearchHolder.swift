//
//  FASearchHolder.swift
//  link-swiftui
//
//  Created by Matt Maddux on 10/1/19.
//  Copyright © 2019 Matt Maddux. All rights reserved.
//

#if os(iOS)

import SwiftUI

class FASearchHolder: ObservableObject {
    
    @Published var searchQuery: String = ""
    @Published var searchResults: [String: FAIcon]?
    
    private var keyboardVisible: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // ======================================================= //
    // MARK: - Methods
    // ======================================================= //
    
    func search() {
        if searchQuery != "" {
            searchResults = FontAwesome.shared.search(query: searchQuery.lowercased())
        }
    }
    
    func clear() {
        searchQuery = ""
        searchResults = nil
    }
    
    // ======================================================= //
    // MARK: - Notification Selectors
    // ======================================================= //
    
    @objc func keyBoardWillShow(notification: Notification) {
        if !keyboardVisible {
            keyboardVisible = true
        }
    }

    @objc func keyBoardDidHide(notification: Notification) {
        if keyboardVisible {
            keyboardVisible = false
            if searchQuery != "" {
                search()
            }
        }
    }
}

#endif
